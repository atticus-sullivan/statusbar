package cpu

import (
	"context"
	"fmt"
	"io"
	"time"

	pscpu "github.com/shirou/gopsutil/v4/cpu"
	"statusbar/blocks"
)

const prefix = 'U'
const interval = 10 * time.Second
const icon = ''

func Cpu(ctx context.Context, f io.Writer) {
	// init library
	_,_ = pscpu.Percent(0, false)
	time.Sleep(1*time.Second)

	var color string
	timer := time.NewTimer(interval)
	for {
		color = ""

		percent, err := pscpu.Percent(0, false)
		if err != nil {
			goto next
		}

		switch {
		case percent[0] > 80:
		color = "%{B#ff0000}"
		}

		fmt.Fprintf(f, "%[1]c %[2]c%2.2[3]f%% \n", prefix, icon, percent[0], color)

		next:
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}
