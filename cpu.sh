#!/bin/sh

file="/media/daten/scripts/statusbar/cpu.stat"

read cpuActiveOld cpuTotalOld < "$file"

read cpu user nice system idle iowait irq softirq steal rest < /proc/stat
#echo "$cpu user:$user nice:$nice system:$system idle:$idle iowait:$iowait irq:$irq softirq:$softirq steal:$steal rest:$rest"

cpuActiveNew=$((user+system+nice+softirq+steal))
cpuTotalNew=$((user+system+nice+softirq+steal+idle+iowait))

cpuActive=$(( cpuActiveNew-cpuActiveOld ))
cpuTotal=$(( cpuTotalNew-cpuTotalOld ))

cpuUssageVk=$(( cpuActive * 100 / cpuTotal ))
cpuUssageNk=$(( cpuActive * 100 % cpuTotal ))

printf "%.2d,%.2d%%\n"  "$cpuUssageVk" "${cpuUssageNk::2}"

printf "%s %s\n" "$cpuActiveNew" "$cpuTotalNew" > "$file"

exit
