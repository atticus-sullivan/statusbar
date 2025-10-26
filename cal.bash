#!/bin/bash

#set -x

ans=besetzt

displayMonth=0
calMonth=now

while [[ "$ans" != "" && "$ans" != "q" ]]
do

	clear
	cal -w "$calMonth"

	read -rp "(< od. >) " -n 1 ans

	if [[ "$ans" == "<" ]]
	then
		displayMonth=$(( displayMonth - 1 ))

	elif [[ "$ans" == ">" ]]
	then
		displayMonth=$(( displayMonth + 1 ))

	fi

	if [[ $displayMonth -lt 0 ]]
	then
		calMonth="${displayMonth#-} months ago"
	elif [[ $displayMonth -eq 0 ]]
	then
		calMonth="now"
	else
		calMonth="+${displayMonth} months"
	fi
done
