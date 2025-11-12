#!/usr/bin/env python3
"""
Monday.com CLI Tool
-------------------

Usage examples:
  monday boards listall
  monday boards list <BOARD_ID>

  monday task show <ITEM_ID>
  monday task show <ITEM_ID> --last-n 2

  monday task update <ITEM_ID> "Note text"
  monday task update <ITEM_ID> --modify-last "Replace last update"
  monday task update <ITEM_ID> --state DONE
"""

import os
import sys
import json
import requests
import typer
from rich import print
from rich.console import Console

console = Console()
app = typer.Typer(help="Monday.com CLI tool")
boards_app = typer.Typer(help="Work with boards")
task_app = typer.Typer(help="Work with individual tasks")
app.add_typer(boards_app, name="boards")
app.add_typer(task_app, name="task")

API_URL = "https://api.monday.com/v2"
TOKEN = os.getenv("MONDAY_API_TOKEN")

if not TOKEN:
    typer.secho("❌ Please set the MONDAY_API_TOKEN environment variable.", fg="red")
    sys.exit(1)

HEADERS = {"Authorization": TOKEN, "Content-Type": "application/json"}

# -------------------------------
# Helpers
# -------------------------------
def run_query(query: str, variables: dict = None):
    payload = {"query": query}
    if variables:
        payload["variables"] = variables
    resp = requests.post(API_URL, headers=HEADERS, json=payload)
    resp.raise_for_status()
    data = resp.json()
    if "errors" in data:
        console.print(f"[red]❌ API error:[/red] {data['errors']}")
        sys.exit(1)
    return data["data"]

# -------------------------------
# Boards Commands
# -------------------------------
@boards_app.command("listall")
def list_all_boards(show_subitems: bool = typer.Option(
    False, "--show-subitems", help="Include subitem-only boards"
)):
    """List all boards available to you."""
    query = """
    {
      boards {
        id
        name
      }
    }
    """
    data = run_query(query)
    boards = data["boards"]

    console.print("[bold]Your Boards:[/bold]")
    for board in boards:
        name = board["name"]
        if not show_subitems and name.startswith("Subitems of"):
            continue
        console.print(f"{board['id']:>8} : {name}")


@boards_app.command("list")
def list_board_items(board_id: int):
    """List all tasks (items) on a board."""
    query = f"""
    {{
      boards(ids:{board_id}) {{
        name
        items_page {{
          items {{
            id
            name
            column_values {{
              id
              text
            }}
          }}
        }}
      }}
    }}
    """
    data = run_query(query)
    board = data["boards"][0]
    items = board["items_page"]["items"]

    console.print(f"[bold]Board {board['name']} ({board_id})[/bold]")
    max_width = max(len(item["id"]) for item in items)

    for item in items:
        status_text = ""
        for col in item["column_values"]:
            if "status" in col["id"].lower():
                status_text = col["text"]
                break

        name = item["name"]
        status_lower = (status_text or "").lower()
        if "blocked" in status_lower:
            color = "red"
        elif status_lower in ("todo", "to do", "to-do"):
            color = "grey50"
        elif status_lower in ("done", "complete", "closed", "finished"):
            color = "green"
        else:
            color = "#ff9900"

        console.print(f"{item['id'].rjust(max_width)} : [{color}]{name}[/{color}] ({status_text})")

# -------------------------------
# Task Commands
# -------------------------------
@task_app.command("show")
def show_task(
    item_id: int,
    last_n: int = typer.Option(1, "--last-n", help="Show last N updates"),
):
    """Show a task's details and its latest updates."""
    query = """
    query($item_id: [ID!]) {
      items(ids: $item_id) {
        id
        name
        board { name }
        column_values { id text }
        updates (limit: 10) { body created_at }
      }
    }
    """
    data = run_query(query, {"item_id": str(item_id)})
    item = data["items"][0]

    console.print(f"[bold underline]{item['name']}[/bold underline] (ID: {item['id']})")
    for col in item["column_values"]:
        if col["text"]:
            console.print(f"  [dim]{col['id']}[/dim]: {col['text']}")

    updates = item.get("updates", [])
    if updates:
        console.print("\n[bold]Recent Updates:[/bold]")
        for upd in updates[:last_n]:
            console.print(f"🕓 {upd['created_at']}\n{upd['body']}\n")
    else:
        console.print("[italic grey50]No updates yet.[/italic grey50]")

@task_app.command("update")
def update_task(
    item_id: int,
    note: str = typer.Argument(None),
    modify_last: str = typer.Option(None, "--modify-last", help="Replace last update text"),
    state: str = typer.Option(None, "--state", help="Set task state: DONE | BLOCKED | TODO | INPROGRESS"),
):
    """Add, modify, or update a task."""
    if not any([note, modify_last, state]):
        typer.secho("❌ Must specify one of: note | --modify-last | --state", fg="red")
        raise typer.Exit(1)

    # (A) Add or replace an update note
    if note or modify_last:
        body = modify_last or note
        mutation = """
        mutation($item_id: ID!, $note: String!) {
          create_update(item_id: $item_id, body: $note) { id }
        }
        """
        run_query(mutation, {"item_id": str(item_id), "note": body})
        msg = "Modified last note" if modify_last else "Added note"
        console.print(f"📝 {msg} for item {item_id}")

    # (B) Change task status
    if state:
        status_map = {"INPROGRESS": 0, "DONE": 1, "BLOCKED": 2, "TODO": 5}
        key = state.upper()
        if key not in status_map:
            typer.secho("❌ Invalid state. Use: DONE | BLOCKED | TODO | INPROGRESS", fg="red")
            raise typer.Exit(1)

        board_query = """
        query($item_id: [ID!]) {
          items(ids: $item_id) { board { id } }
        }
        """
        board_id = run_query(board_query, {"item_id": str(item_id)})["items"][0]["board"]["id"]

        mutation = """
        mutation($board_id: ID!, $item_id: ID!, $value: JSON!) {
          change_column_value(
            board_id: $board_id,
            item_id: $item_id,
            column_id: "status",
            value: $value
          ) { id }
        }
        """
        value_json = json.dumps({"index": status_map[key]})
        vars = {"board_id": str(board_id), "item_id": str(item_id), "value": value_json}
        run_query(mutation, vars)
        console.print(f"✅ Updated STATUS → [bold]{key}[/bold]")

# -------------------------------
# Entry
# -------------------------------
if __name__ == "__main__":
    app()
