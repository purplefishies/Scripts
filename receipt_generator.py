#!/usr/bin/env python

import argparse
import re
import datetime
import shutil
import urllib.parse
import os.path;
import subprocess

#from urllib.parse import unquote, urlparse,quote

def parse_filename(filename,args):
    # Define regular expressions to extract relevant information from the filename
    p_pattern = r'(?:P|Payee)=([^_]+?)[_\.]'
    a_pattern = r'(?:A|Amt|Ammout)=\$([\d.]+)'
    d_pattern = r'(?:(?:D|Date)=|Doc\. )([\d-\.]+)'
    f_pattern = r'(?:F|From)=([^_]+)'
    t_pattern = r'(?:T|To)=([^_]+)'
    tags_pattern = r'tags=([^_\.]+)'

    # Use regular expressions to extract information from the filename
    try: 
        payee = re.search(p_pattern, filename,re.IGNORECASE).group(1)
    except:
        print("Error!")

    amount = re.search(a_pattern, filename,re.IGNORECASE).group(1)
    try:
        date = re.search(d_pattern, filename,re.IGNORECASE).group(1)
    except: 
        # Get the current date
        current_date = args.date
        # Format the date as YYYY/MM/DD
        date = args.date

    try:
        to_acct = re.search(t_pattern, filename,re.IGNORECASE).group(1)
    except:
        to_acct = args.to

    try:
        from_acct = re.search(f_pattern, filename,re.IGNORECASE).group(1)
    except:
        from_acct = getattr(args,"from")

    try:
        tags = re.search(tags_pattern, filename,re.IGNORECASE).group(1).split(',')
    except:
        tags = None


    return payee, amount, date, to_acct, tags, from_acct, filename

def generate_ledger_entry(args):

    payee, amount, date, to_acct, tags, from_acct, filename = parse_filename(args.filename, args)
    entry = f"{date} {payee}\n"
    entry += f"    {from_acct}   ${amount}\n"
    entry += f"    {to_acct}\n"
    entry += f"    ; tags:{','.join(tags)}\n" if tags else ""
    nfile = ""
    urifile = ""
    if args.backup :
        ndir = args.backup + "/" + re.sub(r'/\d{2}$','', date )
        os.makedirs(ndir,exist_ok=True )
        nfile = os.path.abspath(ndir + "/" + filename )
        urifile = subprocess.run(f"uri '{nfile}'", shell=True, capture_output=True, text=True).stdout
        shutil.copyfile(filename, nfile )
    else:
        urifile = urllib.parse.quote(os.path.abspath(filename))
        
    entry += f"    ; {urifile}\n"

    return entry

def main():
    now = datetime.datetime.now().strftime("%Y/%m/%d")
    parser = argparse.ArgumentParser(description="Generate GNU Ledger entry from a filename")
    parser.add_argument("--filename" , required=True,type=str, help="Input filename" , action='store')
    parser.add_argument("--from"     , nargs='?', default=""   , required=False,type=str, help="From Account"    , action='store')
    parser.add_argument("--to"       , nargs='?', default=""   , required=False,type=str, help="To Account"      , action='store')
    parser.add_argument("--date"     , nargs='?', default=now  , required=False,type=str, help="Date"            , action='store')
    parser.add_argument("--tag"      , nargs='?', default=""   , required=False,type=str, help="Tag"             , action='store')
    parser.add_argument("--backup"   , nargs='?', default=""   , required=False,type=str, help="Backup directory", action='store')    
    args = parser.parse_args()

    ledger_entry = generate_ledger_entry(args)

    # Append the ledger entry to the specified ledger file
    with open("ledger.txt", "a") as ledger_file:
        ledger_file.write("\n")
        ledger_file.write(ledger_entry)

if __name__ == "__main__":
    main()
