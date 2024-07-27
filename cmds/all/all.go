package main

import (
	"context"
	"io"
	"os"
	"os/signal"
	"statusbar/blocks/clock"
	"statusbar/blocks/cpu"
	"statusbar/blocks/disk"
	"statusbar/blocks/logitech"
	"statusbar/blocks/mem"
	"statusbar/blocks/battery"
	"statusbar/blocks/netspeed"
	"statusbar/blocks/sxChord"
	"statusbar/blocks/volume"
	"statusbar/blocks/wifi"
	"sync"
	"syscall"

	"github.com/alexflint/go-arg"
)

type args struct {
	Fn string `arg:"positional,required"`
}

func main() {
	var args args
	var err error
	arg.MustParse(&args)

	var f io.WriteCloser
	if args.Fn == "-" {
		f = os.Stdout
	} else {
		f,err = os.OpenFile(args.Fn, os.O_WRONLY, 0600)
		if err != nil {
			panic(err)
		}
		defer f.Close()
	}

	wg := sync.WaitGroup{}
	ctx,cancel := context.WithCancel(context.Background())

	wg.Add(1)
	go func() {
		wifi.Wifi(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		netspeed.NetSpeed(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		battery.Battery(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		cpu.Cpu(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		disk.Zfs(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		mem.Mem(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		clock.Clock(ctx, f)
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		logitech.Logitech(ctx, f)
		wg.Done()
	}()

	// not really able to terminate -> do not wait for it
	go func() {
		sxChord.SxChord(ctx, f)
	}()

	wg.Add(1)
	go func() {
		volume.Volume(ctx, f)
		wg.Done()
	}()

	defer wg.Wait()

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGTERM, syscall.SIGINT)
	<-signals
	cancel()
}
