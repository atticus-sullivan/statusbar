#!/bin/sh

volstat="$(amixer get Master)"

echo "$volstat" | grep "\[off\]" >/dev/null && icon="" #alternative: deaf:  mute: 

vol=$(echo "$volstat" | grep -o "\[[0-9]\+%\]" | sed "s/[^0-9]*//g;1q")

if [ -z "$icon" ] ; then
if [ "$vol" -gt "70" ]; then
	icon=""
elif [ "$vol" -lt "30" ]; then
	icon=""
else
	icon=""
fi
fi

printf "%s %3s%%\n" "$icon" "$vol"
