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
import json
import typer

@app.command()
def update(
    item_id: int,
    note: str = typer.Argument(None),
    set_status: str = typer.Option(
        None, "--set-status", "-s",
        help="Set task status: DONE | BLOCKED | TODO | INPROGRESS",
    ),
):
    """
    Add a note and/or update the Status column of an item.
    Uses numeric status indexes and passes value as a JSON *string*
    while the GraphQL var is typed JSON! (Monday's requirement).
    """

    if not note and not set_status:
        typer.secho("❌ You must provide either a note or --set-status.", fg="red")
        raise typer.Exit(1)

    # 1) Optional: add note
    if note:
        mutation = """
        mutation($item_id: ID!, $note: String!) {
          create_update(item_id: $item_id, body: $note) { id }
        }
        """
        run_query(mutation, {"item_id": str(item_id), "note": note})
        typer.secho(f"📝 Added note to item {item_id}", fg="cyan")

    # 2) Optional: set status
    if set_status:
        status_index_map = {
            "INPROGRESS": 0,
            "DONE": 1,
            "BLOCKED": 2,
            "TODO": 5,
        }
        key = set_status.upper()
        if key not in status_index_map:
            typer.secho("❌ Invalid status. Use: DONE | BLOCKED | TODO | INPROGRESS", fg="red")
            raise typer.Exit(1)

        # fetch board_id for this item
        board_query = """
        query($item_id: [ID!]) {
          items(ids: $item_id) { board { id } }
        }
        """
        board_id = run_query(board_query, {"item_id": str(item_id)})["items"][0]["board"]["id"]

        # IMPORTANT:
        # - var type is JSON!
        # - value MUST be a JSON STRING (e.g., '{"index":1}')
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

        value_json_string = json.dumps({"index": status_index_map[key]})  # e.g., '{"index":1}'

        vars = {
            "board_id": str(board_id),
            "item_id": str(item_id),
            "value": value_json_string,  # JSON! var receiving a JSON-encoded string
        }
        run_query(mutation, vars)
        typer.secho(f"✅ Updated STATUS → {key} (index {status_index_map[key]})", fg="green")



# -------------------------------
# Entry
# -------------------------------
if __name__ == "__main__":
    app()
