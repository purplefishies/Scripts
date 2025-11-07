#!/usr/bin/env python3
"""
Upload images in an exported HTML file to Confluence,
rewrite <img src> paths to uploaded attachments,
then create or update a Confluence page.

Usage:
    ./upload_to_confluence.py --page "Cloudsmith Docs" --html cloudsmith.html
    ./upload_to_confluence.py --page "Docs" --html page.html --url https://site/wiki
"""

import os
import typer
import toml
from pathlib import Path
from bs4 import BeautifulSoup
from atlassian import Confluence

app = typer.Typer(help="Upload HTML + images to Confluence")

DEFAULT_CONFIG = Path("~/.confluencerc").expanduser()


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

def load_config(config_path: Path):
    if config_path.exists():
        return toml.load(config_path)
    return {}


def upsert_page(confluence, space: str, title: str, html: str) -> str:
    """
    Ensure the Confluence page exists, then update its contents.
    Returns the page_id.
    """
    page = confluence.get_page_by_title(space, title)
    if not page:
        typer.secho(f"➕ Creating page '{title}' in space '{space}'", fg=typer.colors.GREEN)
        page = confluence.create_page(space=space, title=title, body=html, parent_id=None)

    page_id = page["id"]
    typer.secho(f"✏️  Updating '{title}' (id={page_id})", fg=typer.colors.GREEN)
    confluence.update_or_create(parent_id=page_id, title=title, body=html)
    return page_id


# ------------------------------------------------------------
# Command
# ------------------------------------------------------------

@app.command()
def upload(
    page: str = typer.Option(..., "--page", "-p", help="Confluence page title"),
    html: Path = typer.Option(..., "--html", "-h", exists=True, help="HTML file to publish"),
    url: str = typer.Option(None, "--url", help="Override Confluence URL"),
    config: Path = typer.Option(
        DEFAULT_CONFIG, "--config", "-c",
        help="Optional TOML config file", show_default=True
    ),
):
    """Upload images referenced in HTML to Confluence and publish the page."""

    # --- Load config ---
    cfg = load_config(config)
    CONFLUENCE_URL = url or cfg.get("CONFLUENCE_URL")
    SPACE_KEY      = cfg.get("SPACE_KEY")
    AUTH_EMAIL     = cfg.get("AUTH_EMAIL")
    API_TOKEN      = os.getenv("ATLASSIAN_API_TOKEN")

    if not API_TOKEN:
        typer.secho("❌ ATLASSIAN_API_TOKEN not set in environment.", fg=typer.colors.RED)
        raise typer.Exit(1)
    if not (CONFLUENCE_URL and AUTH_EMAIL and SPACE_KEY):
        typer.secho("❌ Missing required config keys: AUTH_EMAIL, CONFLUENCE_URL, SPACE_KEY", fg=typer.colors.RED)
        raise typer.Exit(1)

    typer.secho(f"🔗 Connecting to {CONFLUENCE_URL}", fg=typer.colors.BLUE)
    confluence = Confluence(url=CONFLUENCE_URL, username=AUTH_EMAIL, password=API_TOKEN, cloud=True)

    # --- Parse HTML ---
    soup = BeautifulSoup(html.read_text(encoding="utf-8"), "html.parser")
    html_dir = html.parent

    # --- Ensure page exists before uploading attachments ---
    page_id = None
    existing = confluence.get_page_by_title(SPACE_KEY, page)
    if existing:
        page_id = existing["id"]
    else:
        page_id = upsert_page(confluence, SPACE_KEY, page, "<p>Initializing page...</p>")

    # --- Upload images ---
    for img in soup.find_all("img"):
        src = img.get("src")
        if not src:
            continue

        local_img = (html_dir / src).resolve()
        if not local_img.exists():
            typer.secho(f"⚠️  Missing image: {local_img}", fg=typer.colors.YELLOW)
            continue

        typer.secho(f"📤 Uploading image: {local_img}", fg=typer.colors.BLUE)
        uploaded = confluence.attach_file(local_img, page_id=page_id)
        if uploaded:
            img["src"] = uploaded  # replace with Confluence URL

    # --- Write back updated HTML ---
    final_html = str(soup)
    upsert_page(confluence, SPACE_KEY, page, final_html)

    typer.secho("✅ Upload complete!", fg=typer.colors.GREEN)


# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
if __name__ == "__main__":
    app()
