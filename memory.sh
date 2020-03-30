#!/bin/sh

free -h --si | awk '/^Mem:/ {printf " %3s\n", $7}'
