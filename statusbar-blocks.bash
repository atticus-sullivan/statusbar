#!/bin/sh

#########################
## HEADER with LICENSE ##
#########################
# This script displays the battery state (state, percentage, remaining time) with font awesome icons.
# Version: 1.0
# Author: Lukas, fork of LukeSmith's script modified to add notify-send and display remaining time etc.
# Email: l.untrusted+bashScripts@protonmail.com
# Copyright 2020 Lukas
# License: GPL3
# see more information on: https://www.gnu.org/licenses/gpl-3.0.en.html or in the license file of the git repo

#prefixes: B,C,D,K,M,N,S,U,V,s,b
#prefixes taken by bspwm: T,W

bluetooth(){
	local prefix=b

	local res="$(bluetoothctl show | grep -o "Powered: .*")"
	res="${res#Powered: }"
	if [[ "$res" == "no" ]]
	then
		state="n"
		[[ "$1" == "-t" ]] && bluetoothctl power on >&/dev/null && state="y"
	else
		state="y"
		[[ "$1" == "-t" ]] && bluetoothctl power off &>/dev/null &&  state="n"
	fi
	color="%{F#BA5551}"
	[[ "$state" == "y" ]] && color="%{F#96AF82}"
	printf "${prefix}%s%s%s%s\n" "%{A:statusbar-update bluetooth:}" "$color" "$state" "%{A}"
}

#prefix: B
#interval: 10
battery(){
	local interval=10
	local prefix=B

	local battery=/sys/class/power_supply/BAT0
		while true
		do
		# Get its remaining capacity and charge status.
		local capacity=$(cat "$battery"/capacity) || continue
		local status=$(cat "$battery"/status)
				unset color


		if [ "$status" = "Discharging"  ]
		then
			local charge="$(cat "$battery"/charge_now)"
			local current="$(cat "$battery"/current_now)"
			local hour="$(( charge / current ))"
			local min="$(( (charge * 60 / current) - hour*60 ))"


			if [ "$capacity" -gt 75 ]
			then
				local icon=""
			elif [ "$capacity" -gt 50 ]
			then
				local icon=""
			elif [ "$capacity" -gt 25 ]
			then
				local icon=""
				color="%{F#ffb300}"
			elif [ "$capacity" -gt 5 ]
			then
				local icon=""
				color="%{B#ff8000}"
			else
				local icon=""
				color="%{B#ff0000}"
				notify-send -h string:x-canonical-private-synchronous:battery "Battery" "Battery state is critical"
			fi
		elif [ "$status" = "Charging" ]
		then
			local icon=""
			local hour="00"
			local min="00"
		elif [ "$status" = "Full" ]
		then
			local icon="⚡" #alternative: 
			local hour="00"
			local min="00"
		else
			local icon=""
			local hour="00"
			local min="00"
		fi
		printf "${prefix}%s %s %.2d%% %.2d:%.2d%s \n" "$color" "$icon" "$capacity" "$hour" "$min" ""
		sleep $interval
	done
}

#prefix: C
#interval: 1
clock(){
	local prefix=C
	local interval=1
	while true
	do
		#printf "${prefix}%s %s%s\n" "%{F#1259b9}" "$(date '+%d.%m %H:%M:%S')" "%{F-}"
		printf "${prefix}%s  %s%s%s \n" "%{A:st -g 24x10+1680+20 -c calendar -t calendar -e /media/daten/coding/variousBashScripts/cal.bash &:}" "$(date '+%d.%m %H:%M:%S')" "%{F-}" "%{A}"
		sleep $interval
	done
}

#prefix: U
#interval: 10
cpuUsage(){
	local prefix=U
	local interval=10

	local cpuActiveOld=0
	local cpuTotalOld=0

	local cpu user nice system idle iowait irq softirq steal rest

	while true
	do
		read cpu user nice system idle iowait irq softirq steal rest < /proc/stat

		local cpuActiveNew=$((user+system+nice+softirq+steal))
		local cpuTotalNew=$((user+system+nice+softirq+steal+idle+iowait))

		local cpuActive=$(( cpuActiveNew-cpuActiveOld ))
		local cpuTotal=$(( cpuTotalNew-cpuTotalOld ))

		local cpuUssageVk=$(( cpuActive * 100 / cpuTotal )) #vorKomma
		local cpuUssageNk=$(( cpuActive * 100 % cpuTotal )) #nachKomma

		if [[ "$cpuUssageVk" -gt 80 ]]
		then
			color="%{B#ff0000}"
		else
			color=""
		fi
		printf "${prefix}%s %.2d,%.2d%% \n" "$color" "$cpuUssageVk" "${cpuUssageNk::2}"

		local cpuActiveOld="$cpuActiveNew"
		local cpuTotalOld="$cpuTotalNew"
		sleep $interval
	done
}

#prefix: D*
#interval: 1m
diskZFS(){
	local prefix=D
	local interval=1m
	[ -z "$1" ] && exit
	
	while true
	do
		#achive: 
		#compact disk: 
		#folder: 
		#hdd: 
		printf "${prefix}  %-3s \n" "$(zfs list $1 | tr -s " " | awk ' /[0-9]/ {print $3}')"
		sleep $interval
	done
}

#prefix: K*
capsLock(){
	prefix=K
	xset q | awk -F'   ' '/Caps Lock/{print "K" $3}' | sed "s/on/%{B#ff0000} C /;s/off/    /"
}

#prefix: S
#interval: 5
wifi(){
	local prefix=S
	local interval=5
	if [[ "$1" == "-o" ]]
	then
		[ "$(cat /sys/class/net/w*/operstate)" = 'down' ] && local wifiicon="" ||
			local wifiicon=$(grep "^\s*w" /proc/net/wireless | awk '{ print "", int($3 * 100 / 70) "%" }')

		printf "${prefix}%s%s %s%s\n" "%{A:/media/daten/scripts/networkmanager-dmenu.bash:}" "$wifiicon" "$(sed "s/down/ /;s/up//" /sys/class/net/e*/operstate)" "%{A}"
		return
	fi

	while true
	do
		[ "$(cat /sys/class/net/w*/operstate)" = 'down' ] && local wifiicon="" ||
			local wifiicon=$(grep "^\s*w" /proc/net/wireless | awk '{ print "", int($3 * 100 / 70) "%" }')

		printf "${prefix}%s%s %s%s\n" "%{A:/media/daten/scripts/networkmanager-dmenu.bash:}" "$wifiicon" "$(sed "s/down/ /;s/up//" /sys/class/net/e*/operstate)" "%{A}"
		sleep $interval
	done
}

#prefix: N
#interval 5
netspeed(){
	local prefix=N
	local interval=5

	local oldRx=0
	local oldTx=0
	local oldTime=0

	local newRx newTx newTime upB formatPrintU formatPrintD downVk downNk upVk upNk unitD unitU baseD baseU

	while true
	do
		if [[ $(cat /sys/class/net/wlp64s0/operstate) == up ]]
		then
			read newRx < /sys/class/net/wlp64s0/statistics/rx_bytes
			read newTx < /sys/class/net/wlp64s0/statistics/tx_bytes
		else
			read newRx < /sys/class/net/enp59s0f1/statistics/rx_bytes
			read newTx < /sys/class/net/enp59s0f1/statistics/tx_bytes
		fi
		newTime=$(date +%s)
		timeDiff=$((newTime - oldTime))

		downB=$(( (newRx-oldRx) / timeDiff ))
		  upB=$(( (newTx-oldTx) / timeDiff ))

		oldRx="$newRx"
		oldTx="$newTx"
		oldTime="$newTime"

		formatPrintD="%2d,%.2d%2s" #alternative:  
		formatPrintU="%2d,%.2d%2s\n" #alternative: 

		if [ "$downB" -lt 0 ]
		then
			downVk="00"
			downNk="00"
			unitD=B
		elif [ "$downB" -lt 100 ]
		then
			baseD=1
			downVk=$(( downB / baseD ))
			downNk="00"
			unitD=B
		else
			if [ "$downB" -lt 100000 ]
			then
				baseD=1000
				unitD=KB
			else
				baseD=1000000
				unitD=MB
			fi
			downVk=$(( downB / baseD ))
			downNk=$(( (downB % baseD) / (baseD/100) ))
		fi
		printf "${prefix}$formatPrintD" "$downVk" "$downNk" "${unitD}"

		printf " " #delimiter

		if [ "$upB" -lt 0 ]
		then
			upVk="00"
			upNk="00"
			unitU=B
		elif [ "$upB" -lt 100 ]
		then
			baseU=1
			upVk=$(( upB / baseU ))
			upNk="00"
			unitU=B
		else
			if [ "$upB" -lt 100000 ]
			then
				baseU=1000
				unitU=KB
			else
				baseU=1000000
				unitU=MB
			fi
			upVk=$(( upB / baseU ))
			upNk=$(( (upB % baseU) / (baseU/100) ))
		fi
		printf "$formatPrintU" "$upVk" "$upNk" "${unitU}"
		sleep $interval
	done
}

#prefix: M*
#interval: 5
memory(){
	local prefix=M
	local interval=5
	while true
	do
		free -h --si | awk '/^Mem:/ {printf "M  %3s \n", $7}'
		sleep $interval
	done
}

#prefix: V
volume(){
	prefix=V
	# while true
	# do
	volstat="$(amixer get Master 2>/dev/null)"

		echo "$volstat" | grep "\[off\]" >/dev/null && icon="" #alternative: deaf:  mute: 

		vol=$(echo "$volstat" | grep -o "\[[0-9]\+%\]" | sed "s/[^0-9]*//g;1q")

		if [ -z "$icon" ] ; then
			if [ "$vol" -gt "50" ]; then
				icon=""
			#elif [ "$vol" -gt "30" ]; then
			#	icon=""
			else
				icon=""
			fi
		fi

		printf "${prefix}%s %s %3s%% %s\n" "%{A:amixer set Master toggle; statusbar-update volume:}" "$icon" "$vol" "%{A}"
		# sleep 20
	# done
}

#prefix: s
sxChord(){
	prefix=s
	state=""
	printf "${prefix}  \n"
	RED=""
	SXHKD_FIFO=/tmp/sx-fifo
	while read sxEvent
	do
		# if [[ "$sxEvent" == "Hsuper + shift + r" ]] #TODO add alternatives
		if [[ "$sxEvent" == "EEnd chain" ]]
		then
			state=""
			printf "${prefix}  \n"
		elif [[ "$sxEvent" == "BBegin chain" ]]
		then
			state="chain"
			printf "${prefix}%sC\n" "${RED}"
		fi
		# if [[ "$state" == "chain" ]]
		# then
		# else
		# fi
	done <"${SXHKD_FIFO}"
}

tmp(){
	while true
	do
	capsLock
	sleep 20
done
}

startStatus(){
	killall battery clock cpuUsage diskZFS capslock netspeed memory volume wifi sxChord bluetooth

	local waitingFor
	battery &
	clock &
	cpuUsage &
	diskZFS data &
	capsLock &
	# tmp &
	wifi &
	netspeed &
	memory &
	volume &
	sxChord &
	bluetooth &

	# update only on signal
	trap -- tmp RTMIN+1
	trap -- "volume ; wait" RTMIN+2

	# update in intervall and when receiving signal
	#trap -- "pkill -SIGUSR1 <func>" RTMIN+3
	#trap -- "pkill -SIGUSR1 <func>" RTMIN+4
	#trap -- "pkill -SIGUSR1 <func>" RTMIN+5

	wait
}
