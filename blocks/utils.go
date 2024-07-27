package blocks

import (
	"context"
	"time"
)

// returns whether ctx is done
// automatically resets the timer to the given interval
func Sleep(timer *time.Timer, interval time.Duration, ctx context.Context) bool {
	for {
		select {
		case <- timer.C:
			timer.Reset(interval)
			return false
		case <-ctx.Done():
			return true
		}
	}
}

func FormatBytes(bytes float64) (float64, string) {
	var unit string
	var base float64

	if bytes < 100 {
		unit = "B"
		base = 1
	} else if bytes < 100_000 {
		unit = "KB"
		base = 1_000
	} else if bytes < 100_000_000 {
		unit = "MB"
		base = 1_000_000
	} else {
		unit = "GB"
		base = 1_000_000_000
	}

	mainValue := bytes / base
	return mainValue, unit
}

