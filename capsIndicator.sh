#!/bin/sh

xset q | awk -F'   ' '/Caps Lock/{print $3}' | sed "s/on/C/;s/off/ /"
