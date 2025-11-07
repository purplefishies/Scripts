    # --- load config ---
    cfg = load_config(config)



    CONFLUENCE_URL = url or cfg.get("CONFLUENCE_URL")
    SPACE_KEY      = cfg.get("SPACE_KEY")
    AUTH_EMAIL     = cfg.get("AUTH_EMAIL")

    API_TOKEN      = os.getenv("ATLASSIAN_API_TOKEN")

    if not API_TOKEN:
        typer.secho("❌ ATLASSIAN_API_TOKEN not set in environment.", fg=typer.colors.RED)
        raise typer.Exit(1)

    if not CONFLUENCE_URL or not AUTH_EMAIL or not SPACE_KEY:
        typer.secho("❌ Missing required config keys: AUTH_EMAIL, CONFLUENCE_URL, SPACE_KEY", fg=typer.colors.RED)
        raise typer.Exit(1)

    typer.secho(f"🔗 Connecting to {CONFLUENCE_URL}", fg=typer.colors.BLUE)

    confluence = Confluence(
        url=CONFLUENCE_URL,
        username=AUTH_EMAIL,
        password=API_TOKEN
    )

    # load html
    html_str = html.read_text(encoding="utf-8")
    soup = BeautifulSoup(html_str, "html.parser")

    # find page, or create new
    page_info = confluence.get_page_by_title(SPACE_KEY, page)
    page_id = page_info["id"] if page_info else None

    if page_id:
        typer.secho(f"✏️  Updating page: {page}", fg=typer.colors.GREEN)
    else:
        typer.secho(f"➕ Creating new page: {page}", fg=typer.colors.GREEN)

    # --- Upload images ---
    for img in soup.find_all("img"):
        src = img.get("src")
        if not src:
            continue

        local_img = Path(src.strip("./"))

        if not local_img.exists():
            typer.secho(f"⚠️   Missing image: {local_img}", fg=typer.colors.YELLOW)
            continue

        filename = local_img.name
        typer.secho(f"📤 Uploading image: {filename}", fg=typer.colors.CYAN)

        # upload attachment linked to page_id (or a new temp id if creating)
        confluence.attach_file(
            page_id if page_id else 0,
            file=str(local_img),
            name=filename
        )

        # rewrite src -> attachment url
        img["src"] = f"{CONFLUENCE_URL}/download/attachments/{page_id}/{filename}?api=v2"

    # convert soup back to HTML
    final_html = str(soup)

    # push HTML to confluence
    confluence.update_or_create(
        parent_id=None,
        title=page,
        space=SPACE_KEY,
        body=final_html
    )

    typer.secho("✅ Upload complete!", fg=typer.colors.GREEN)

if __name__ == "__main__":
    app()
