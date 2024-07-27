package disk

import (
	"context"
	"fmt"
	"io"
	"os/exec"
	"strings"
	"time"
	"statusbar/blocks"
	// zfs "github.com/bicomsystems/go-libzfs"
)

const prefix = 'D'
const icon = ''
const name = "data"
const interval = 1 * time.Minute

func ZfsOnce(f io.Writer) error {
	usage, err := getZFSUsage(name)
	if err != nil {
		return err
	}

	fmt.Fprintf(f, "%[1]c %[2]c %[3]s \n", prefix, icon, usage)
	return nil
}

func Zfs(ctx context.Context, f io.Writer) {
	timer := time.NewTimer(interval)
	for {
		ZfsOnce(f)

		if exit := blocks.Sleep(timer, interval, ctx); exit {
			return
		}
	}
}

// func getZFSUsage(poolName string) (string, error) {
// 	dataset, err := zfs.DatasetOpen(poolName)
// 	if err != nil {
// 		return "", err
// 	}
// 	defer dataset.Close()
//
// 	used, err := dataset.GetProperty(zfs.DatasetPropUsed)
// 	if err != nil {
// 		return "", err
// 	}
// 	return used.Value, nil
// }

func getZFSUsage(poolName string) (string, error) {
	cmd := exec.Command("zfs", "list", poolName)
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	lines := strings.Split(string(output), "\n")
	if len(lines) < 2 {
		return "", fmt.Errorf("unexpected output from zfs list")
	}

	fields := strings.Fields(lines[1])
	if len(fields) < 3 {
		return "", fmt.Errorf("unexpected output from zfs list")
	}

	return fields[2], nil
}
