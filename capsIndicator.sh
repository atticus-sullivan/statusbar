#!/bin/sh

xset q | awk -F'   ' '/Caps Lock/{print $3}' | sed "s/on/^b#ff0000^^c#ffffff^C^d^/;s/off/ /"
