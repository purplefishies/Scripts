#!/bin/bash

sudo mkdir -p /media/jdamon/Development

sudo mount -t ext4 -orw,nosuid,nodev,uhelper=udisks2 /dev/sda1 /media/jdamon/Development
