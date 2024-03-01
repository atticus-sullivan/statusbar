#!/bin/bash

# provides: startStatus battery clock cpuUsage diskZFS capslock netspeed memory volume wifi
source statusbar-blocks
PANEL_FIFO=/tmp/panel-fifo

if [[ "$1" == start ]]
then
	startStatus
else
	case "$1" in
		bluetooth)
			bluetooth "-t";;
		volume)
			# notify-send update volume
			volume;;
		caps)
			# notify-send update capslock
			sleep 0.2
			capsLock;;
		wifi)
			# notify-send update wifi
			wifi -o;;
	esac >> ${PANEL_FIFO}
fi
