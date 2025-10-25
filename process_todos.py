#!/usr/bin/env python3
import argparse
import shutil
from datetime import datetime
from pathlib import Path

EXTS = {".pdf", ".png", ".jpg", ".jpeg"}

def process_file(src: Path, todos_base: Path, org_file: Path, processed_dir: Path):
    if not (src.is_file() and src.suffix.lower() in EXTS):
        return

    now = datetime.now()
    year = f"{now.year}"
    month = now.strftime("%b")   # Jan, Feb, Mar, ... Oct, Nov, Dec

    dest_dir = todos_base / year / month
    dest_dir.mkdir(parents=True, exist_ok=True)
    processed_dir.mkdir(parents=True, exist_ok=True)
    org_file.parent.mkdir(parents=True, exist_ok=True)

    dest_file = dest_dir / src.name
    shutil.copy2(src, dest_file)

    captured = now.strftime("%Y-%m-%d %a %H:%M")
    rel_path = f"Todos/{year}/{month}/{src.name}"
    entry = f"""** TODO {src.name}
:PROPERTIES:
:CAPTURED:  <{captured}>
:END:

    [[file:{rel_path}]]

"""
    with open(org_file, "a", encoding="utf-8") as f:
        f.write(entry)

    shutil.move(str(src), processed_dir / src.name)
    print(f"Processed: {src.name} -> {dest_file}")

def main():
    p = argparse.ArgumentParser(description="Process scanned files into Org Todos and archive originals.")
    p.add_argument("--watch", required=True, help="Folder to process (e.g. ~/Scanned)")
    p.add_argument("--org-root", default="~/Dropbox/org", help="Org root directory (Todos/ is created under this)")
    p.add_argument("--orgfile", default="~/Dropbox/org/Todos/inbox.org", help="Org capture file to append to")
    args = p.parse_args()

    watch_dir = Path(args.watch).expanduser()
    if not watch_dir.is_dir():
        raise RuntimeError(f"Watch folder {watch_dir} does not exist or is not a directory")

    todos_base = Path(args.org_root).expanduser() / "Todos"
    org_file = Path(args.orgfile).expanduser()
    processed_dir = watch_dir / "Processed"

    for src in watch_dir.iterdir():
        process_file(src, todos_base, org_file, processed_dir)

if __name__ == "__main__":
    main()


