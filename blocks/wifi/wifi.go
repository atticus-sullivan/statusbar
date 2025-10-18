package wifi

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"statusbar/blocks"
	"strconv"
	"strings"
	"time"
)

const prefix = 'S'
const interval = 5 * time.Second
const icon = ''

func WifiOnce(f io.Writer) error {
	iface, err := getWirelessIface()
	if err != nil {
		return err
	}

	signalStrength, err := getWirelessSignalStrength(iface)
	if err != nil {
		return err
	}
	fmt.Fprintf(f, "%[1]c%[2]s%[4]c%02.0[5]f%% %[3]s\n", prefix, "%{A:/media/daten/scripts/networkmanager-dmenu.bash:}", "%{A}", icon, signalStrength)

	return nil
}

func Wifi(ctx context.Context, f io.Writer) {

	timer := time.NewTimer(interval)
	for {
		WifiOnce(f)
		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}


func getWirelessSignalStrength(interfaceName string) (float64, error) {
	data, err := os.ReadFile("/proc/net/wireless")
	if err != nil {
		return 0, err
	}
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		if strings.Contains(line, interfaceName) {
			fields := strings.Fields(line)
			if len(fields) > 2 {
				signalStrength, err := strconv.ParseFloat(fields[2], 64)
				if err == nil {
					return signalStrength * 100 / 70, nil
				}
			}
		}
	}
	return 0, errors.New("iface not found")
}

func getWirelessIface() (string, error) {
	interfaces, _ := net.Interfaces()
	for _, iface := range interfaces {
		if strings.HasPrefix(iface.Name, "w") && iface.Flags&net.FlagUp != 0 {
			return iface.Name, nil
		}
	}
	return "", errors.New("no wireless iface found")
}
