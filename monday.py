#!/usr/bin/env python3
import os
import sys
import requests
import typer
from rich import print  # <-- add this at the top of the file


app = typer.Typer(help="Monday.com CLI tool for boards, tasks, and notes")
boards_app = typer.Typer(help="Work with boards")
app.add_typer(boards_app, name="boards")

API_URL = "https://api.monday.com/v2"
TOKEN = os.getenv("MONDAY_API_TOKEN")

if not TOKEN:
    typer.echo("❌ Please set the MONDAY_API_TOKEN environment variable.")
    sys.exit(1)

HEADERS = {
    "Authorization": TOKEN,
    "Content-Type": "application/json"
}

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
        typer.echo(f"❌ API error: {data['errors']}")
        sys.exit(1)
    return data["data"]

# -------------------------------
# Boards Commands
# -------------------------------
@boards_app.command("list")
def list_boards(show_subitems: bool = typer.Option(
    False,
    "--show-subitems",
    help="Include subitem-only boards (names starting with 'Subitems of ...')"
)):
    """
    List all boards: <id> : <name>
    """
    query = """
    {
      boards {
        id
        name
      }
    }
    """
    data = run_query(query)

    for board in data["boards"]:
        name = board["name"]
        # Hide subitems unless flag is set
        if not show_subitems and name.startswith("Subitems of"):
            continue

        typer.echo(f"{board['id']} : {name}")


@boards_app.command("listall")
def list_board_items(
    board_id: int,
    colorize: bool = typer.Option(
        False,
        "--colorize",
        help="Colorize task names (green = done, orange/red = not done)"
    ),
):
    """
    List all tasks on a board: <id> : <name>
    """
    query = f"""
    {{
      boards(ids:{board_id}) {{
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
    items = data["boards"][0]["items_page"]["items"]

    print(f"[bold]Board {board_id} items:[/bold]")


    max_width = max(len(item["id"]) for item in items)

    for item in items:
        status_text = ""
        for col in item["column_values"]:
            if "status" in col["id"].lower():
                status_text = col["text"]
                break

        name = item["name"]

        # Colorize only the name
        if colorize:
            if status_text.lower() in ("done", "complete", "closed", "finished"):
                name = f"[bold green]{name}[/bold green]"
            else:
                name = f"[bold #ff6600]{name}[/bold #ff6600]"

        # Right-align and pad ID based on max width
        padded_id = item["id"].rjust(max_width)

        print(f"{padded_id} : {name}")


# -------------------------------
# Items Commands (kept flat)
# -------------------------------
@app.command()
def show(item_id: int):
    """
    Show all updates (notes) for a task
    """
    query = f"""
    {{
      items(ids:{item_id}) {{
        id
        name
        updates {{
          id
          body
          created_at
          creator {{ name }}
        }}
      }}
    }}
    """
    data = run_query(query)
    item = data["items"][0]
    typer.echo(f"Task {item['id']} : {item['name']}")
    typer.echo("-" * 50)
    updates = item["updates"]
    if not updates:
        typer.echo("No updates yet.")
    for u in updates:
        typer.echo(f"{u['created_at']} [{u['creator']['name']}]: {u['body']}")

@app.command()
def update(item_id: int, note: str):
    """
    Add a note (update) to a task
    """
    query = """
    mutation($item_id: ID!, $note: String!) {
      create_update(item_id: $item_id, body: $note) {
        id
      }
    }
    """
    variables = {"item_id": str(item_id), "note": note}
    data = run_query(query, variables)
    update_id = data["create_update"]["id"]
    typer.echo(f"✅ Added note {update_id} to item {item_id}")

# -------------------------------
# Entry
# -------------------------------
if __name__ == "__main__":
    app()
