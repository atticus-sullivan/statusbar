package sxChord

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os"
)

func SxChord(ctx context.Context, f io.Writer) {
	prefix := 's'

	SXHKD_FIFO := "/tmp/sx-fifo"

	file, err := os.Open(SXHKD_FIFO)
	if err != nil {
		os.Stderr.WriteString("failed to open sx-fifo\n")
		return
	}
	defer file.Close()

	// var inChain bool
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		sxEvent := scanner.Text()

		if sxEvent == "EEnd chain" {
			// inChain = false
			fmt.Fprintf(f, "%[1]c   \n", prefix)
		} else if sxEvent == "BBegin chain" {
			// inChain = true
			fmt.Fprintf(f, "%[1]c%[2]s C\n", prefix, "")
		}

		select {
		case <-ctx.Done():
			return
		default:
		}
	}

	if err := scanner.Err(); err != nil {
		os.Stderr.WriteString("failed to read from sx-fifo\n")
		return
	}
}
