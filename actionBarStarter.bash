#!/bin/bash

resp=$(printf "%s\n" "test" "tut1" "LaTeX" "GDB" | dmenu)

~/.config/bspwm/actionBar.bash "$resp"
exit
