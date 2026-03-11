#!/usr/bin/env python3

import argparse
import os
import shutil
from pathlib import Path
from datetime import datetime

def append_to_inbox(inbox_path, title, file_path):
    created_date = datetime.now().strftime("<%Y-%m-%d>")
    with open(inbox_path, 'a') as inbox_file:
        inbox_file.write(f"\n** {title}\n")
        inbox_file.write(f"     :PROPERTIES:\n")
        inbox_file.write(f"     :CREATED: {created_date}\n")
        inbox_file.write(f"     :END:\n")
        inbox_file.write(f"    [[file:{file_path}]]\n\n")

def move_and_process_file(file_path, destination, inbox_path):
    file_name = file_path.name
    year = datetime.now().year
    destination_year_dir = Path(destination) / str(year)
    destination_year_dir.mkdir(parents=True, exist_ok=True)
    
    new_file_path = destination_year_dir / file_name
    shutil.move(file_path, new_file_path)

    title = file_name.split("todo_", 1)[-1].rsplit(".pdf", 1)[0]
    append_to_inbox(inbox_path, title, new_file_path)
    print(f"Processed and moved: {file_name}")

def process_directory(directory, destination, inbox_path):
    current_files = set(Path(directory).glob("*.pdf"))
    for file_path in current_files:
        move_and_process_file(file_path, destination, inbox_path)

def main():
    parser = argparse.ArgumentParser(description="Process new todo files from a directory and exit.")
    parser.add_argument('--directory', required=True, help='Directory to watch for new files.')
    parser.add_argument('--destination', required=True, help='Destination directory to move files.')
    parser.add_argument('--inbox', required=True, help='Inbox file to append new entries.')

    args = parser.parse_args()

    process_directory(args.directory, args.destination, args.inbox)

if __name__ == '__main__':
    main()

