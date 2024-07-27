package battery

import (
	"context"
	"fmt"
	"io"
	"time"

	"github.com/distatus/battery"
	"statusbar/blocks"
)

var (
	ICON_100 rune = ''
	ICON_50 rune = ''
	ICON_25 rune = ''
	ICON_05 rune = ''
	ICON_00 rune = ''
	ICON_CH rune = ''
	ICON_FULL rune = '⚡'
	ICON_DK rune = ''
)

const prefix = 'B'
const interval = 5 * time.Second

func BatteryOnce(f io.Writer) error {
	var icon rune
	var capacity float64
	var color string

	bat, err := battery.Get(0)
	if err != nil {
		return err
	}

	capacity = bat.Current/bat.Full*100
	color = ""

	switch bat.State.Raw {
	case battery.Charging:
		duration, err := time.ParseDuration(fmt.Sprintf("%fh", (bat.Full - bat.Current) / bat.ChargeRate))
		if err != nil {
			duration = 0
		}
		icon = ICON_CH
		fmt.Fprintf(f, "%[1]c %[2]c%.0[3]f%% %[4]s \n", prefix, icon, capacity, duration.Truncate(time.Minute))
		return nil

	case battery.Discharging:
		duration, err := time.ParseDuration(fmt.Sprintf("%fh", bat.Current / bat.ChargeRate))
		if err != nil {
			duration = 0
		}
		switch {
		case capacity > 75:
			icon = ICON_100
		case capacity > 50:
			icon = ICON_50
		case capacity > 25:
			icon = ICON_25
			color="%{F#ffb300}"
		case capacity > 5:
			icon = ICON_05
			color="%{B#ff8000}"
		default:
			icon = ICON_00
			color="%{B#ff0000}"
		}
		fmt.Fprintf(f, "%[1]c%[4]s %[2]c%.0[3]f%% %[5]s \n", prefix, icon, capacity, color, duration.Truncate(time.Minute))
		return nil

	case battery.Full:
		icon = ICON_FULL
	case battery.Empty:
		icon = ICON_00
	case battery.Idle:
		icon = ICON_100
	case battery.Unknown:
		icon = ICON_DK
	}

	fmt.Fprintf(f, "%[1]c %[2]c%.0[3]f%% \n", prefix, icon, capacity)
	return nil
}

func Battery(ctx context.Context, f io.Writer) {
	timer := time.NewTimer(interval)
	for {
		BatteryOnce(f)
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}
