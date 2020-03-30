#!/bin/sh

[ "$(cat /sys/class/net/w*/operstate)" = 'down' ] && wifiicon="      " ||
	wifiicon=$(grep "^\s*w" /proc/net/wireless | awk '{ print "", int($3 * 100 / 70) "%" }')

printf "  %s %s\n" "$wifiicon" "$(sed "s/down/ /;s/up//" /sys/class/net/e*/operstate)"
