package volume

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"statusbar/blocks"
	"strconv"
	"strings"
	"time"
)
var (
	VOL0 = ''
	VOL50 = ''
	VOL100 = ''
)

const prefix = 'V'
const interval = 5 * time.Second

func VolumeOnce(f io.Writer) error {
	var icon rune
	v, err := getVolumeStatus()
	if err != nil {
		return err
	}

	if v.Muted {
		icon = VOL0
	} else {
		switch {
		case v.VolumeR > 50:
			icon = VOL100
		default:
			icon = VOL50
		}
	}

	if v.Left && v.Right {
		if v.VolumeL == v.VolumeR {
			fmt.Fprintf(f, "%[1]c%[2]s %[4]c %[5]d%% %[3]s\n", prefix, "%{A:amixer set Master toggle; statusbar-update volume:}", "%{A}", icon, v.VolumeR)
		} else {
			fmt.Fprintf(f, "%[1]c%[2]s %[4]c %[5]d|%[6]d%% %[3]s\n", prefix, "%{A:amixer set Master toggle; statusbar-update volume:}", "%{A}", icon, v.VolumeL, v.VolumeR)
		}
	} else if v.Left && !v.Right {
		fmt.Fprintf(f, "%[1]c%[2]s %[4]c %[5]d%% %[3]s\n", prefix, "%{A:amixer set Master toggle; statusbar-update volume:}", "%{A}", icon, v.VolumeL)
	} else if !v.Left && v.Right {
		fmt.Fprintf(f, "%[1]c%[2]s %[4]c %[5]d%% %[3]s\n", prefix, "%{A:amixer set Master toggle; statusbar-update volume:}", "%{A}", icon, v.VolumeR)
	} else {
		fmt.Fprintf(f, "%[1]c%[2]s %[4]c %[5]d%% %[3]s\n", prefix, "%{A:amixer set Master toggle; statusbar-update volume:}", "%{A}", icon, 0)
	}
	return nil
}

func Volume(ctx context.Context, f io.Writer) {
	timer := time.NewTimer(interval)
	for {
		VolumeOnce(f)

		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}

type VolumeStatus struct {
	VolumeR int
	Right bool

	VolumeL int
	Left bool

	VolumeM int
	Mono bool

	Muted  bool
}

func getVolumeStatus() (VolumeStatus, error) {
	cmd := exec.Command("amixer", "get", "Master")
	output, err := cmd.Output()
	if err != nil {
		return VolumeStatus{}, err
	}

	return parseAmixerOutput(output)
}

var reVol = regexp.MustCompile(`^(.+): Playback \d+ \[(\d+)%\] \[(off|on)\]`)

func parseAmixerOutput(output []byte) (VolumeStatus, error) {
	var err error
	scanner := bufio.NewScanner(bytes.NewReader(output))

	var vs VolumeStatus

	for scanner.Scan() {
		line := scanner.Text()
		line = strings.TrimSpace(line)

		matches := reVol.FindStringSubmatch(line)
		if len(matches) < 1 {
			continue
		}

		switch matches[3] {
		case "off":
			vs.Muted = true
		case "on":
			vs.Muted = false
		default:
			os.Stderr.WriteString("invalid mute signal\n")
		}

		var vol int
		if vol, err = strconv.Atoi(matches[2]); err != nil {
			continue
		}

		switch matches[1] {
		case "Front Left":
			vs.VolumeL = vol
			vs.Left = true
		case "Front Right":
			vs.VolumeR = vol
			vs.Right = true
		default:
			os.Stderr.WriteString("invalid position\n")
		}
	}

	return vs, nil
}
