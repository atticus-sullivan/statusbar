#!/bin/sh

# Status bar module for disk space
# $1 should be drive mountpoint
# $2 is optional icon, otherwise mountpoint will displayed

[ -z "$1" ] && exit

#achive: 
#compact disk: 
#folder: 
#hdd: 

printf "%-3s\n" "$(df -h "$1" | awk ' /[0-9]/ {print $3}')"
