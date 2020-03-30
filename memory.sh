#!/bin/sh

free -h --si | awk '/^Mem:/ {printf "%.2d" $7}'
