#!/usr/bin/env python3
"""
Upload images in an exported HTML file to Confluence,
rewrite <img src> paths to uploaded attachments,
then create or update the Confluence page.

Usage:
    ./upload_to_confluence.py --page "Docs" --html page.html
    ./upload_to_confluence.py --page "Docs" --html page.html --url https://site/wiki
"""

import os
from pathlib import Path
import typer
import toml
from bs4 import BeautifulSoup
from atlassian import Confluence

app = typer.Typer(help="Upload HTML + images to Confluence")

DEFAULT_CONFIG = Path("~/.confluencerc").expanduser()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_config(config_path: Path):
    return toml.load(config_path) if config_path.exists() else {}


def upsert_page(confluence, space: str, title: str, html: str) -> str:
    """
    Ensure that the page exists, then update its contents.
    Returns the page_id.
    """
    page = confluence.get_page_by_title(space, title)

    if not page:
        typer.secho(f"➕ Creating page '{title}' in space '{space}'", fg=typer.colors.GREEN)
        page = confluence.create_page(
            space=space,
            title=title,
            body=html,
            parent_id=None,
        )

    page_id = page["id"]

    typer.secho(f"✏️  Updating '{title}' (id={page_id})", fg=typer.colors.GREEN)
    confluence.update_or_create(
        parent_id=page_id,
        title=title,
        body=html,
    )

    return page_id


# ---------------------------------------------------------------------------
# Main Typer command
# ---------------------------------------------------------------------------

@app.command()
def upload(
    page: str = typer.Option(..., "--page", "-p", help="Confluence page title"),
    html: Path = typer.Option(..., "--html", "-h", exists=True, help="HTML file to publish"),
    url: str = typer.Option(None, "--url", help="Override Confluence URL"),
    config: Path = typer.Option(DEFAULT_CONFIG, "--config", "-c", help="TOML config file", show_default=True),
):
    """
    Upload images referenced in HTML to Confluence and publish the page.
    """

    # ------------------------------------
    # Load Configuration
    # ------------------------------------
    cfg = load_config(config)

    CONFLUENCE_URL = url or cfg.get("CONFLUENCE_URL")
    SPACE_KEY      = cfg.get("SPACE_KEY")
    AUTH_EMAIL     = cfg.get("AUTH_EMAIL")
    API_TOKEN      = os.getenv("ATLASSIAN_API_TOKEN")

    if not API_TOKEN:
        typer.secho("❌ ATLASSIAN_API_TOKEN not set in environment", fg=typer.colors.RED)
        raise typer.Exit(1)

    if not (CONFLUENCE_URL and AUTH_EMAIL and SPACE_KEY):
        typer.secho("❌ Missing required config keys: AUTH_EMAIL, CONFLUENCE_URL, SPACE_KEY", fg=typer.colors.RED)
        raise typer.Exit(1)

    typer.secho(f"🔗 Connecting to Confluence: {CONFLUENCE_URL}", fg=typer.colors.BLUE)

    confluence = Confluence(
        url=CONFLUENCE_URL,
        username=AUTH_EMAIL,
        password=API_TOKEN,
        cloud=True,
    )

    # ------------------------------------
    # Load and parse HTML
    # ------------------------------------
    soup = BeautifulSoup(html.read_text(encoding="utf-8"), "html.parser")
    html_dir = html.parent

    # ------------------------------------
    # Upload <img> files as attachments
    # ------------------------------------
    for img in soup.find_all("img"):
        src = img.get("src")
        if not src:
            continue

        local_img = (html_dir / src).resolve()

        if not local_img.exists():
            typer.secho(f"⚠️  Missing image: {local_img}", fg=typer.colors.YELLOW)
            continue

        typer.secho(f"📤 Uploading image: {local_img}", fg=typer.colors.BLUE)

        # We must ensure page exists BEFORE uploading
        page_id = confluence.get_page_by_title(SPACE_KEY, page)
        if page_id:
            page_id = page_id["id"]
        else:
            page_id = upsert_page(confluence, SPACE_KEY, page, "<p>Temporary placeholder</p>")

        url = confluence.attach_file(local_img, page_id=page_id)

        img["src"] = url  # rewrite HTML to use Confluence URL

    # ------------------------------------
    # Commit HTML
    # ------------------------------------
    final_html = str(soup)
    upsert_page(confluence, SPACE_KEY, page, final_html)

    typer.secho("✅ Upload complete!", fg=typer.colors.GREEN)


if __name__ == "__main__":
    app()
