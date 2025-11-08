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
    Update page if it exists, otherwise create it.
    """
    page_id = confluence.get_page_id(space, title)

    # ✅ CREATE
    if not page_id:
        typer.secho(f"➕ Creating page '{title}' in '{space}'", fg=typer.colors.GREEN)
        page = confluence.create_page(
            space=space,
            title=title,
            body=html,
            representation="storage"
        )
        return page["id"]

    # ✅ UPDATE
    typer.secho(f"✏️ Updating '{title}' (id={page_id})", fg=typer.colors.GREEN)
    confluence.update_page(
        page_id=page_id,
        title=title,
        body=html,
        representation="storage"
    )

    return page_id

def fix_internal_anchors_and_links(soup: BeautifulSoup, page_title: str):
    """
    - For every element with an id=..., insert an Anchor macro:
        <ac:structured-macro ac:name="anchor"><ac:parameter ac:name="">id</ac:parameter></ac:structured-macro>
    - Rewrite <a href="#id">Text</a> to a Confluence storage link:
        <ac:link><ri:page ri:content-title="..."/><ri:anchor ri:anchor="id"/><ac:plain-text-link-body>Text</ac:plain-text-link-body></ac:link>
    """
    added = set()

    # 1) Insert anchor macros for all ids
    for el in soup.select('[id]'):
        anchor = el.get('id')
        if not anchor or anchor in added:
            continue
        # Confluence anchor names must be plain text; your org ids are fine as-is
        macro = soup.new_tag("ac:structured-macro")
        macro.attrs["ac:name"] = "anchor"
        param = soup.new_tag("ac:parameter")
        param.attrs["ac:name"] = ""
        param.string = anchor
        # Put the macro immediately before the target element
        el.insert_before(macro.append(param) or macro)
        added.add(anchor)

    # 2) Rewrite intra-page links
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if not href.startswith("#"):
            continue
        anchor = href[1:]
        text = a.get_text() or anchor

        ac_link = soup.new_tag("ac:link")
        ri_page = soup.new_tag("ri:page")
        ri_page.attrs["ri:content-title"] = page_title
        ri_anchor = soup.new_tag("ri:anchor")
        ri_anchor.attrs["ri:anchor"] = anchor
        body = soup.new_tag("ac:plain-text-link-body")
        body.string = text

        ac_link.append(ri_page)
        ac_link.append(ri_anchor)
        ac_link.append(body)
        a.replace_with(ac_link)


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

    # --- Load config TOML ---
    cfg = load_config(config)
    CONFLUENCE_URL = url or cfg.get("CONFLUENCE_URL")
    SPACE_KEY      = cfg.get("SPACE_KEY")
    AUTH_EMAIL     = cfg.get("AUTH_EMAIL")
    API_TOKEN      = os.getenv("ATLASSIAN_API_TOKEN")

    if not API_TOKEN:
        typer.secho("❌ ATLASSIAN_API_TOKEN not set", fg=typer.colors.RED)
        raise typer.Exit(1)
    if not (CONFLUENCE_URL and AUTH_EMAIL and SPACE_KEY):
        typer.secho("❌ Missing required config keys in TOML: AUTH_EMAIL, CONFLUENCE_URL, SPACE_KEY", fg=typer.colors.RED)
        raise typer.Exit(1)

    typer.secho(f"🔗 Connecting to {CONFLUENCE_URL}", fg=typer.colors.BLUE)
    confluence = Confluence(url=CONFLUENCE_URL, username=AUTH_EMAIL, password=API_TOKEN, cloud=True)

    # --- Parse HTML file ---
    soup = BeautifulSoup(html.read_text(encoding="utf-8"), "html.parser")
    html_dir = html.parent

    # ✅ Page MUST exist to upload attachments
    page_id = confluence.get_page_id(SPACE_KEY, page)
    if not page_id:
        typer.secho(f"➕ Creating initial page '{page}'", fg=typer.colors.GREEN)
        created = confluence.create_page(
            space=SPACE_KEY,
            title=page,
            body="<p>Initializing…</p>",
            representation="storage"
        )
        page_id = created["id"]

    # --- Upload images and rewrite to Confluence storage format ---
    for img in soup.find_all("img"):
        src = img.get("src")
        if not src:
            continue

        local_img = (html_dir / src).resolve()

        if not local_img.exists():
            typer.secho(f"⚠️ Missing image: {local_img}", fg=typer.colors.YELLOW)
            continue

        typer.secho(f"📤 Uploading image: {local_img}", fg=typer.colors.BLUE)
        uploaded = confluence.attach_file(local_img, page_id=page_id)

        # ✅ Convert <img> to Confluence <ac:image><ri:attachment/>
        ac_image = soup.new_tag("ac:image")
        ri_attach = soup.new_tag("ri:attachment", attrs={"ri:filename": local_img.name})
        ac_image.append(ri_attach)

        img.replace_with(ac_image)

    # --- Convert soup back to Confluence storage format HTML ---
    final_html = str(soup)

    typer.secho(f"✏️ Updating '{page}' (id={page_id})", fg=typer.colors.GREEN)
    confluence.update_page(
        page_id=page_id,
        title=page,
        body=final_html,
        representation="storage",
    )

    typer.secho("✅ Upload complete!", fg=typer.colors.GREEN)



# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
if __name__ == "__main__":
    app()
