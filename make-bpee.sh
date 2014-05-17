#!/bin/sh
make bpee rom=bpee.gba offset=DE4020
printf '\x20\x40\xde\x08' | dd of=bpee.gba conv=notrunc seek=3014896 bs=1