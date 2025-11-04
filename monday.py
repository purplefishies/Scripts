#!/usr/bin/env python3
import os
import sys
import requests
import typer

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
def list_boards():
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
        typer.echo(f"{board['id']} : {board['name']}")

@boards_app.command("listall")
def list_board_items(board_id: int):
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
          }}
        }}
      }}
    }}
    """
    data = run_query(query)
    items = data["boards"][0]["items_page"]["items"]
    typer.echo(f"Board {board_id} items:")
    for item in items:
        typer.echo(f"{item['id']} : {item['name']}")

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
