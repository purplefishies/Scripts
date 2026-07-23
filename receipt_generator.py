#!/usr/bin/env python3

import argparse
import re
import datetime
import shutil
import os
from pathlib import Path


def parse_filename(filename, args):
    p_pattern = r'(?:P|Payee)=([^_]+?)[_\.]'
    a_pattern = r'(?:A|Amt|Ammout)=\$?([\d.]+)'
    d_pattern = r'^(\d{4}[-./]\d{2}[-./]\d{2})'
    f_pattern = r'(?:F|From)=([^_]+)'
    t_pattern = r'(?:T|To)=([^_]+)'
    tags_pattern = r'tags=([^_\.]+)'

    payee_match = re.search(p_pattern, filename, re.IGNORECASE)
    if not payee_match:
        raise ValueError(f"Could not parse payee from filename: {filename}")
    payee = payee_match.group(1)

    amount_match = re.search(a_pattern, filename, re.IGNORECASE)
    if not amount_match:
        raise ValueError(f"Could not parse amount from filename: {filename}")
    amount = amount_match.group(1)

    leading_date_pattern = r'^(\d{4}[-/]\d{2}[-/]\d{2})'
    named_date_pattern = r'(?:D|Date)=(\d{4}[-/]\d{2}[-/]\d{2})'
    
    date_match = (
        re.search(leading_date_pattern, os.path.basename(filename), re.IGNORECASE)
        or re.search(named_date_pattern, filename, re.IGNORECASE)
    )
    
    if date_match:
        date = date_match.group(1).replace("-", "/")
    else:
        date = args.date



    to_match = re.search(t_pattern, filename, re.IGNORECASE)
    to_acct = to_match.group(1) if to_match else args.to

    from_match = re.search(f_pattern, filename, re.IGNORECASE)
    from_acct = from_match.group(1) if from_match else getattr(args, "from")

    tags_match = re.search(tags_pattern, filename, re.IGNORECASE)
    tags = tags_match.group(1).split(",") if tags_match else None

    return payee, amount, date, to_acct, tags, from_acct, filename


def generate_ledger_entry(args):
    payee, amount, date, to_acct, tags, from_acct, filename = parse_filename(
        args.filename,
        args,
    )

    entry = f"{date} {payee}\n"
    entry += f"    {from_acct}   ${amount}\n"
    entry += f"    {to_acct}\n"

    if tags:
        entry += f"    ; tags:{','.join(tags)}\n"

    if args.backup:
        ndir = os.path.join(args.backup, re.sub(r'/\d{2}$', '', date))
        os.makedirs(ndir, exist_ok=True)

        base_filename = os.path.basename(filename)
        nfile = os.path.abspath(os.path.join(ndir, base_filename))

        shutil.copyfile(filename, nfile)
        urifile = Path(nfile).resolve().as_uri()
    else:
        urifile = Path(filename).resolve().as_uri()

    entry += f"    ; {urifile}\n"

    return entry


def main():
    now = datetime.datetime.now().strftime("%Y/%m/%d")

    parser = argparse.ArgumentParser(
        description="Generate GNU Ledger entry from a filename"
    )

    parser.add_argument("--filename", required=True, type=str, help="Input filename")
    parser.add_argument("--from", dest="from_acct", default="", type=str, help="From Account")
    parser.add_argument("--to", default="", type=str, help="To Account")
    parser.add_argument("--date", default=now, type=str, help="Date")
    parser.add_argument("--tag", default="", type=str, help="Tag")
    parser.add_argument("--backup", default="", type=str, help="Backup directory")

    args = parser.parse_args()

    # Preserve old getattr(args, "from") behavior.
    setattr(args, "from", args.from_acct)

    ledger_entry = generate_ledger_entry(args)

    with open("ledger.txt", "a") as ledger_file:
        ledger_file.write("\n")
        ledger_file.write(ledger_entry)
        ledger_file.write("\n")

if __name__ == "__main__":
    main()
