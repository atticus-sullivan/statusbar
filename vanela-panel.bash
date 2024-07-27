#!/bin/bash

# Just some comments
# Just a simple Lemonbar script
# Only clickable workspaces, window title, and clock
# Spamming command every second using shell to generate statusline is not really efficient
# So I only put those three items
# If I need other status informations
# I'd rather to call them using Dunst

# Workspace indicator is generated using bspc subscribe
# Which only update if there is an reaction on bspwm
# Window title is generated using xtitle
# Which also has subscribe event ability
# Clock is generated using looped date command
# Only update every thirty seconds

# Based on default example from Bspwm GitHub repository
# Some parts are modified to make them look like what i want
# Cheers! Addy

# Colors
BLACK="#000000"
RED="#e78284"
GREEN="#a6d189"
YELLOW="#e5c890"
BLUE="#8caaee"
MAGENTA="#ca9ee6"
CYAN="#99d1db"
WHITE="#ffffff"

FOREGROUND="#c6d0f5"
BACKGROUND="#303446"

# general variables
PANEL_HEIGHT=20
PANEL_WIDTH=
PANEL_HORIZONTAL_OFFSET=0
PANEL_VERTICAL_OFFSET=0

PANEL_FONT="-*-dejavu sans-medium-r-normal-*-*-*-*-*-*-*-*-*"
PANEL_FIFO=/tmp/panel-fifo
PANEL_WM_NAME=bspwm_panel

COLOR_DEFAULT_FG="$FOREGROUND"
COLOR_DEFAULT_BG="$BACKGROUND"

COLOR_MONITOR_FG="$FOREGROUND"
COLOR_MONITOR_BG="$BACKGROUND"

COLOR_FOCUSED_MONITOR_FG="$FOREGROUND"
COLOR_FOCUSED_MONITOR_BG="$BLUE"

COLOR_FREE_FG="$BLACK"
COLOR_FREE_BG="$BACKGROUND"

COLOR_FOCUSED_FREE_FG="$FOREGROUND"
COLOR_FOCUSED_FREE_BG="$BLUE"

COLOR_OCCUPIED_FG="$FOREGROUND"
COLOR_OCCUPIED_BG="$BACKGROUND"

COLOR_FOCUSED_OCCUPIED_FG="$FOREGROUND"
COLOR_FOCUSED_OCCUPIED_BG="$BLUE"

COLOR_URGENT_FG="$FOREGROUND"
COLOR_URGENT_BG="$YELLOW"

COLOR_FOCUSED_URGENT_FG="$FOREGROUND"
COLOR_FOCUSED_URGENT_BG="$YELLOW"

COLOR_STATE_FG="$FOREGROUND"
COLOR_STATE_BG="$BACKGROUND"

COLOR_TITLE_FG="$FOREGROUND"
COLOR_TITLE_BG="$BACKGROUND"

COLOR_SYS_FG="$FOREGROUND"
COLOR_SYS_BG="$RED"

#make fifo if non existant
[ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
mkfifo "$PANEL_FIFO"

# Just to make sure there is no double process
killall -9 lemonbar xtitle xdo statusbar-all

dmenu_run="%{A:dmenu-launcher:}  %{A}"
flameshot="%{A:flameshot gui:}  %{A}"

# Echo every modules to PANEL_FIFO
statusbar-all "${PANEL_FIFO}" &

xtitle -t 60 -sf 'T%s\n' > "$PANEL_FIFO" &
bspc subscribe report > "$PANEL_FIFO" &
num_mon=$(bspc query -M | wc -l)

# Then read those value
panel_bar() {
while read -r line ; do
	echo "$line" 1>&2
	case $line in
		m*)
			mouseBat="${line#?}%{B-}%{F-}"
			;;
		B*)
			bat="${line#?}%{B-}%{F-}"
			;;
		C*)
			time="${line#?}%{B-}%{F-}"
			;;
		U*)
			cpu="${line#?}%{B-}%{F-}"
			;;
		D*)
			disk="${line#?}%{B-}%{F-}"
			;;
		S*)
			signal="${line#?}%{B-}%{F-}"
			;;
		N*)
			netspeed="${line#?}%{B-}%{F-}"
			;;
		M*)
			mem="${line#?}%{B-}%{F-}"
			;;
		V*)
			vol="${line#?}%{B-}%{F-}"
			;;
		s*)
			sxhkd="${line#?}%{B-}%{F-}"
			;;
		T*)
			# xtitle output
			title="%{F$COLOR_TITLE_FG}%{B$COLOR_TITLE_BG} ${line#?} %{B-}%{F-}"
			;;
		W*)
			# workspaces output
			wm=
			IFS=':'
			set -- ${line#?}
			while [ $# -gt 0 ] ; do
				item=$1
				name=${item#?}
				# printf "$items $name\n" >&2
				case $item in
					[mM]*)
						case $item in
							m*)
								# monitor
								FG=$COLOR_MONITOR_FG
								BG=$COLOR_MONITOR_BG
								on_focused_monitor=
								;;
							M*)
								# focused monitor
								FG=$COLOR_FOCUSED_MONITOR_FG
								BG=$COLOR_FOCUSED_MONITOR_BG
								on_focused_monitor=1
								;;
						esac
						;;
				esac

				# skip workspaces on unfocused monitors
				if [[ "$on_focused_monitor" ]]
				then
					:
				else
					shift
					continue
				fi

				case $item in
					[fFoOuU]*)
						case $item in
							f*)
								# free desktop
								FG=$COLOR_FREE_FG
								BG=$COLOR_FREE_BG
								UL=$BG
								;;
							F*)
								FG=$COLOR_FOCUSED_FREE_FG
								BG=$COLOR_FOCUSED_FREE_BG
								UL=$BG
								;;
							o*)
								# occupied desktop
								FG=$COLOR_OCCUPIED_FG
								BG=$COLOR_OCCUPIED_BG
								UL=$BG
								;;
							O*)
								FG=$COLOR_FOCUSED_OCCUPIED_FG
								BG=$COLOR_FOCUSED_OCCUPIED_BG
								UL=$BG
								;;
							u*)
								# urgent desktop
								FG=$COLOR_URGENT_FG
								BG=$COLOR_URGENT_BG
								UL=$BG
								;;
							U*)
								FG=$COLOR_FOCUSED_URGENT_FG
								BG=$COLOR_FOCUSED_URGENT_BG
								UL=$BG
								;;
						esac
						if [[ "$name" == "0" ]]
						then
							local jump="10"
						else
							local jump="$name"
						fi
						wm="${wm}%{F${FG}}%{B${BG}}%{U${UL}}%{+u}%{A:bspc desktop ^${jump}.!focused -f || bspc desktop last -f:} ${name} %{A}%{B-}%{F-}%{-u}"
						;;
					[LTGS]*)
						# layout, state and flags
						wm="${wm}%{F$COLOR_STATE_FG}%{B$COLOR_STATE_BG} ${name} %{B-}%{F-}"
						;;
				esac
				shift
			done
			;;
	esac
	#printf "%s\n" "%{l}${wm}%{O10}${title} %{r} ${signal} ${netspeed}| ${key}| ${disk}| ${vol}| ${mem}| ${cpu}| ${bat}| ${time}     "
	printf "%s\n" "%{l}${wm} ${sxhkd} %{O10}${title} %{r} |${dmenu_run}|${flameshot}| ${signal} ${netspeed}|${disk}|${vol}|${mem}|${cpu}|${bat}|${mouseBat}|${time}"
done
}

# Get all the results of the modules above then pipe them to Lemonbar
panel_bar < "$PANEL_FIFO" | lemonbar -f "Dejavu Sans" -f 'FontAwesome' -a 16 \
-g "$PANEL_WIDTH"x"$PANEL_HEIGHT"+"$PANEL_HORIZONTAL_OFFSET"+"$PANEL_VERTICAL_OFFSET" \
-f "$PANEL_FONT" -F "$COLOR_DEFAULT_FG" -B "$COLOR_DEFAULT_BG" -n "$PANEL_WM_NAME" | bash & disown

sleep 0.5
# Trigger the PANEL_FIFO to make it instantly refreshed after bspwmrc reloaded 
echo "dummy" > "$PANEL_FIFO"

sleep 0.5
# Rule the panel to make it hiding below fullscreen window
# I add 'sleep 0.5' to avoid xdo executed before the Lemonbar fully loaded
wid=$(xdo id -a "$PANEL_WM_NAME")
xdo above -t "$(xdo id -N Bspwm -n root | sort | head -n 1)" "$wid"

# Don't close this process
wait
