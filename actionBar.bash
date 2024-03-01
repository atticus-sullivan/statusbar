#!/bin/bash

# $1: command
# $2: title
out(){
	printf "%%{A:%s:}%s%%{A} " "$@"
}

case "$1" in
	test)
		printf "test";;
	tut1)
		out "notify-send hi" "testing";;
	LaTeX)
		out "echo 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' | xsel -b" "lore"
		;;
	GDB)
		cd /media/daten/education/studium/semester-03/GDB/uebungsblaetter/Blatt05/tex/
		out "cat listing-2a.lst | xsel -b" "2a" "cat listing-2b1.lst | xsel -b" "2b1" "cat listing-2b2.lst | xsel -b" "2b2"
		;;
	*)
		exit
		;;
esac | { cat ; printf "%s\n" " %{A:pkill -P $$:}|quit|%{A} " ;}| lemonbar -f "Dejavu Sans" -f 'FontAwesome' -a 15 -pd -g x20+960+1040 -n actionBar | bash &


wid=$(xdo id -a "actionBar")
xdo above -t "$(xdo id -N Bspwm -n root | sort | head -n 1)" "$wid"
