package mem

import (
	"context"
	"fmt"
	"io"
	"time"
	"statusbar/blocks"

	psmem "github.com/shirou/gopsutil/v4/mem"
)

const prefix = 'M'
const interval = 5 * time.Second
const icon = ''

func MemOnce(f io.Writer) error {
	var avail float64
	var unit string
	vm, err := psmem.VirtualMemory()
	if err != nil {
		return err
	}

	avail, unit = blocks.FormatBytes(float64(vm.Available))
	fmt.Fprintf(f, "%[1]c%[2]c %.1[3]f%[4]s \n", prefix, icon, avail, unit)
	return nil
}

func Mem(ctx context.Context, f io.Writer) {
	timer := time.NewTimer(interval)
	for {
		MemOnce(f)
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}
