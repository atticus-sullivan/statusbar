#!/bin/sh

# Prints all batteries, their percentage remaining and an emoji corresponding
# to charge status (🔌 for pluged up, 🔋 for discharging on battery, etc.).

ncol="^d^"

# Loop through all attached batteries.
for battery in /sys/class/power_supply/BAT?
do
	# Get its remaining capacity and charge status.
	capacity=$(cat "$battery"/capacity) || exit
	status=$(cat "$battery"/status)

	# If it is discharging and 25% or less, we will add a ❗ as a warning.

	if [ "$status" = "Discharging"  ]
	then
		charge="$(cat "$battery"/charge_now)"
		current="$(cat "$battery"/current_now)"
		hour="$(( charge / current ))"
		min="$(( (charge * 60 / current) - hour*60 ))"

		if [ "$capacity" -gt 75 ]
		then
			icon=""
		elif [ "$capacity" -gt 50 ]
		then
			icon=""
		elif [ "$capacity" -gt 25 ]
		then icon=""
		elif [ "$capacity" -gt 5 ]
		then
			icon=""
		else
			icon=""
			col="^b#ff0000^^c#FFFFFF^"
			notify-send "Battery" "Battery state is critical"
		fi
	elif [ "$status" = "Charging" ]
	then
		icon=""
		hour="00"
		min="00"
	elif [ "$status" = "Full" ]
	then
		icon="⚡" #alternative: 
		hour="00"
		min="00"
	else
		icon=""
		hour="00"
		min="00"
	fi

	printf "%s%s %.2d%% %.2d:%.2d%s\n" "$col" "$icon" "$capacity" "$hour" "$min" "$ncol"
done

