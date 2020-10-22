#!/usr/bin/python2.7

import gnomekeyring as gk
import sys

keyring = 'login'
keyItems = gk.list_item_ids_sync(keyring)

for keyItem in keyItems:
    key = gk.item_get_info_sync(keyring, keyItem)
    if  key.get_display_name() == sys.argv[1]:
        # Your script here using key.get_secret()
        print key.get_secret()


