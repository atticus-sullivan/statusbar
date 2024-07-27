package logitech

import (
	"context"
	"fmt"
	"io"
	"os/exec"
	"regexp"
	"strconv"
	"time"
	"statusbar/blocks"
)

const prefix = 'm'
const interval = 5 * time.Minute
const icon = ''
const serial = "482A112D"

func LogitechOnce(f io.Writer) error {
	var batBAK int
	bat, err := getBatteryLevel(serial)
	if err != nil {
		bat = batBAK
	}
	if bat != 0 {
		fmt.Fprintf(f, "%[1]c %[2]c %.2[3]d%% \n", prefix, icon, bat)
	}
	return nil
}

func Logitech(ctx context.Context, f io.Writer) {

	timer := time.NewTimer(interval)
	for {
		LogitechOnce(f)
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}

var reSolaar = regexp.MustCompile(`     Battery: (\d\d?)`)
func getBatteryLevel(serial string) (int, error) {
	cmd := exec.Command("solaar", "show", serial)
	output, err := cmd.Output()
	if err != nil {
		return -1, err
	}

	// Use regex to extract the battery level
	matches := reSolaar.FindSubmatch(output)
	if len(matches) < 2 {
		return -1, fmt.Errorf("battery level not found")
	}

	batteryLevel, err := strconv.Atoi(string(matches[1]))
	if err != nil {
		return -1, err
	}

	return batteryLevel, nil
}
