#!/usr/bin/env python3

import youtube_dl

ydl_opts={'outtmpl': '%(id)s%(ext)s'}
def dwl_vid():
    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        ydl.download([zxt])

channel = 1
while ( channel == int(1)):
    link_of_the_video = input("Enter Download Link:- ")
    zxt = link_of_the_video.strip()

    dwl_vid()
    channel = int(input("Enter 1 if you want to download mode videos\n Anything else to quit"))
