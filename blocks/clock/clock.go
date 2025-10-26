package clock

import (
	"context"
	"fmt"
	"io"
	"time"

	"statusbar/blocks"
)

const prefix = 'C'
const icon = ''
const interval = 1 * time.Second

func ClockOnce(f io.Writer) {
	now := time.Now()

	fmt.Fprintf(f, "%[1]c %[4]c%[2]s%[5]s%[3]s \n", prefix, "%{A:st -g 24x10+1680+20 -c calendar -t calendar -e vanela-cal &:}", "%{F-}%{A}", icon, now.Format("02.01. 15:04:05"))
}

func Clock(ctx context.Context, f io.Writer) {

	timer := time.NewTimer(interval)
	for {
		ClockOnce(f)
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}
