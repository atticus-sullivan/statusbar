package main

import (
	"io"
	"os"
	"statusbar/blocks/battery"
	"statusbar/blocks/clock"
	"statusbar/blocks/disk"
	"statusbar/blocks/logitech"
	"statusbar/blocks/mem"
	"statusbar/blocks/volume"
	"statusbar/blocks/wifi"
	"statusbar/common"

	"github.com/alexflint/go-arg"
)

type args struct {
	// Fn string `arg:"positional,required"`
	Block string `arg:"-b,required"`
}

func main() {
	var args args
	var err error
	arg.MustParse(&args)

	var f io.WriteCloser
	if common.FIFO == "-" {
		f = os.Stdout
	} else {
		f,err = os.OpenFile(common.FIFO, os.O_WRONLY, 0600)
		if err != nil {
			panic(err)
		}
		defer f.Close()
	}

	switch args.Block {
	case "wifi":
		wifi.WifiOnce(f)
	case "bat":
		battery.BatteryOnce(f)
	case "disk":
		disk.ZfsOnce(f)
	case "mem":
		mem.MemOnce(f)
	case "clock":
		clock.ClockOnce(f)
	case "mouse":
		logitech.LogitechOnce(f)
	case "vol":
		volume.VolumeOnce(f)
	default:
		print("invalid argument passed\n")
		os.Exit(-1)
	}
}
