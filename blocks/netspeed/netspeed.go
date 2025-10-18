package netspeed

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"statusbar/blocks"
	"strings"
	"time"

	psnet "github.com/shirou/gopsutil/v4/net"
)

func getNetworkInterface() (string, error) {
	var wireless string
	var wired string

	interfaces, err := net.Interfaces()
	if err != nil {
		return "", err
	}

	for _, iface := range interfaces {
		if wireless == "" && strings.HasPrefix(iface.Name, "wlp") && iface.Flags & net.FlagRunning != 0 {
			wireless = iface.Name
		}
		if wired == "" && strings.HasPrefix(iface.Name, "enp") && iface.Flags & net.FlagRunning != 0 {
			wired = iface.Name
		}
	}

	switch {
	case wired != "":
		return wired, nil
	case wireless != "":
		return wireless, nil
	default:
		return "", errors.New("No active iface found")
	}
}

func getBytes(ifaceN string) (float64, float64, error) {
	interfaces, err := psnet.IOCounters(true)
	if err != nil {
		return 0, 0, err
	}

	for _, iface := range interfaces {
		if iface.Name == ifaceN {
			return float64(iface.BytesRecv), float64(iface.BytesSent), nil
		}
	}
	return 0, 0, errors.New("iface not found")
}

type status struct {
	rx float64
	tx float64
	t float64
}

func NetSpeed(ctx context.Context, f io.Writer) {
	prefix := 'N'
	interval := 5 * time.Second

	iconDown := ''
	iconUp := ''

	var old, n status
	var down, up float64
	var unitD, unitU string

	// try to obtain values once
	switch {
	case true:
		interfaceName, err := getNetworkInterface()
		if err != nil {
			break
		}
		rx, tx, err := getBytes(interfaceName)
		if err != nil {
			break
		}
		old.rx, old.tx = rx, tx
	}

	old.t = float64(uint64(time.Now().Unix()))

	// infinite loop
	timer := time.NewTimer(interval)
	for {
		n.t = float64(time.Now().Unix())
		interfaceName, err := getNetworkInterface()
		if err != nil {
			goto next
		}

		{
			rx, tx, err := getBytes(interfaceName)
			if err != nil {
				goto next
			}
			n.rx, n.tx = rx, tx
		}

		{
			timeDiff := max(n.t - old.t, 1)
			downB := (n.rx - old.rx) / timeDiff
			upB := (n.tx - old.tx) / timeDiff

			down, unitD = blocks.FormatBytes(downB)
			up, unitU = blocks.FormatBytes(upB)
		}

		fmt.Fprintf(f, "%[1]c %[2]c%2.2[4]f%2[5]s %[3]c%2.2[6]f%[7]s \n", prefix, iconDown, iconUp, down, unitD, up, unitU)

		next:
		old = n

		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}
