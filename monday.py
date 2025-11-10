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
def update(
    item_id: int,
    note: str = typer.Argument(
        None,
        help="Optional note to add to this item"
    ),
    set_status: str = typer.Option(
        None,
        "--set-status",
        "-s",
        help="Set task status: DONE | BLOCKED | TODO | INPROGRESS",
    ),
):
    """
    Add a note and/or update the status column of a task.
    """

    if not note and not set_status:
        typer.secho("❌ You must provide either a note or --set-status.", fg="red")
        raise typer.Exit(1)

    # -----------------------------------------------------------
    # 1. Add note (if specified)
    # -----------------------------------------------------------
    if note:
        mutation = """
        mutation($item_id: ID!, $note: String!) {
          create_update(item_id: $item_id, body: $note) {
            id
          }
        }
        """
        variables = {"item_id": str(item_id), "note": note}
        result = run_query(mutation, variables)
        typer.secho(f"📝 Added note {result['create_update']['id']}", fg="cyan")

    # -----------------------------------------------------------
    # 2. Update status (if specified)
    # -----------------------------------------------------------
    if set_status:
        # map CLI → Monday label
        status_map = {
            "DONE": "Done",
            "BLOCKED": "Blocked",
            "TODO": "To Do",
            "INPROGRESS": "In Progress",
        }

        key = set_status.upper()
        if key not in status_map:
            typer.secho("❌ Invalid status. Use: DONE | BLOCKED | TODO | INPROGRESS.", fg="red")
            raise typer.Exit(1)

        target_label = status_map[key]

        # ---- fetch board id from item ----
        board_query = """
        query($item_id: [ID!]) {
          items(ids: $item_id) {
            board { id }
          }
        }
        """
        board_data = run_query(board_query, {"item_id": str(item_id)})
        board_id = board_data["items"][0]["board"]["id"]

        # ---- IMPORTANT: correct mutation + real JSON ----
        mutation = """
        mutation($board_id: ID!, $item_id: ID!, $value: JSON!) {
          change_column_value(
            board_id: $board_id,
            item_id: $item_id,
            column_id: "status",
            value: $value
          ) {
            id
          }
        }
        """

        # Monday wants a dict here, NOT a JSON-encoded string
        variables = {
            "board_id": str(board_id),
            "item_id": str(item_id),
            "value": {"label": target_label},
        }

        run_query(mutation, variables)
        typer.secho(f"✅ Updated status → {target_label}", fg="green")


# -------------------------------
# Entry
# -------------------------------
if __name__ == "__main__":
    app()
