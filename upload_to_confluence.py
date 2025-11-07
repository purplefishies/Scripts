#!/usr/bin/env python3
"""
Upload HTML + images to Confluence.

Features:
- Parses HTML
- Uploads images as attachments
- Rewrites <img src="..."> to Confluence attachment URLs
- Creates or updates a Confluence page
- Reads defaults from ~/.confluencerc (TOML)
- CLI args override config values

Usage:
  ./upload_to_confluence.py --page "Cloudsmith Docs" --html ./cloudsmith.html
  ./upload_to_confluence.py --page Test --html foo.html --config ./custom_config.toml
"""

import os
from pathlib import Path
import typer
import toml
from bs4 import BeautifulSoup
from atlassian import Confluence

app = typer.Typer(help="Upload HTML + images to Confluence")

DEFAULT_CONFIG = Path.home() / ".confluencerc"


def load_config(config_path: Path | None):
    """Load TOML config; supports default fallback."""
    if config_path and config_path.exists():
        return toml.load(config_path)

    if DEFAULT_CONFIG.exists():
        return toml.load(DEFAULT_CONFIG)

    return {}  # No config found


@app.command()
def upload(
    page: str = typer.Option(..., "--page", "-p", help="Confluence page title"),
    html: Path = typer.Option(..., "--html", "-h", exists=True, help="HTML file to publish"),
    url: str = typer.Option(None, "--url", help="Override Confluence URL"),
    config: Path = typer.Option(None, "--config", "-c", help="Optional .confluencerc TOML config file"),
):
    """
    Upload HTML + images to Confluence, creating or updating the page.
    """

    # --- Load TOML config (custom > default ~/.confluencerc) ---
    cfg = load_config(config)

    confluence_url = url or cfg.get("CONFLUENCE_URL")
    space_key = cfg.get("SPACE_KEY")
    auth_email = cfg.get("AUTH_EMAIL")

    api_token = os.getenv("ATLASSIAN_API_TOKEN")

    # --- Validate required config + token ---
    missing = []
    if not confluence_url: missing.append("CONFLUENCE_URL")
    if not space_key:      missing.append("SPACE_KEY")
    if not auth_email:     missing.append("AUTH_EMAIL")
    if not api_token:      missing.append("ATLASSIAN_API_TOKEN (env var)")

    if missing:
        typer.secho("❌ Missing required settings:", fg=typer.colors.RED)
        for key in missing:
            typer.secho(f"   - {key}", fg=typer.colors.RED)
        typer.echo("\nFix by adding to ~/.confluencerc or --config TOML:")
        typer.echo("\nExample TOML (~/.confluencerc):\n")
        typer.echo("""\
AUTH_EMAIL = "you@company.com"
CONFLUENCE_URL = "https://your-company.atlassian.net/wiki"
SPACE_KEY = "ENG"
        """)
        raise typer.Exit(1)

    typer.secho(f"🔗 Connecting to: {confluence_url}", fg=typer.colors.BLUE)

    confluence = Confluence(
        url=confluence_url,
        username=auth_email,
        password=api_token,
    )

    # --- Load HTML content ---
    html_str = html.read_text(encoding="utf-8")
    soup = BeautifulSoup(html_str, "html.parser")

    # --- Find page (or create new) ---
    page_info = confluence.get_page_by_title(space_key, page)
    page_id = page_info["id"] if page_info else None

    typer.secho(
        "✏️  Updating page..." if page_id else "➕ Creating page...",
        fg=typer.colors.GREEN,
    )

    # --- Upload images ---
    for img in soup.find_all("img"):
        src = img.get("src")
        if not src:
            continue

        local = Path(src.strip("./"))  # clean up relative paths

        if not local.exists():
            typer.secho(f"⚠️ Missing image: {local}", fg=typer.colors.YELLOW)
            continue

        filename = local.name
        typer.secho(f"📤 Uploading image: {filename}", fg=typer.colors.CYAN)

        confluence.attach_file(
            page_id or 0,  # Confluence API needs an ID; works even on first push
            file=str(local),
            name=filename,
        )

        img["src"] = f"{confluence_url}/download/attachments/{page_id}/{filename}?api=v2"

    # Final HTML update
    final_html = str(soup)

    confluence.update_or_create(
        parent_id=None,
        title=page,
        space=space_key,
        body=final_html,
    )

    typer.secho("✅ Upload complete!", fg=typer.colors.GREEN)


if __name__ == "__main__":
    app()
