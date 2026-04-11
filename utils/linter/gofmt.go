// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import (
	"fmt"
	"os/exec"
	"strings"
)

// CheckGoFormatting runs gofmt -l against the file.
// Returns an error if the file needs formatting, nil if clean.
func CheckGoFormatting(path string) error {
	cmd := exec.Command("gofmt", "-l", path)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("gofmt: %s: %v\n%s", path, err, string(output))
	}
	if strings.TrimSpace(string(output)) != "" {
		return fmt.Errorf("%s: needs formatting (gofmt)", path)
	}
	return nil
}

// FixGoFormatting runs gofmt -l -w against the file.
// Reports to stderr if the file was modified.
func FixGoFormatting(path string) error {
	cmd := exec.Command("gofmt", "-l", "-w", path)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("gofmt: failed to format %s: %v\n%s", path, err, string(output))
	}
	if strings.TrimSpace(string(output)) != "" {
		fmt.Printf("%s: fixed (gofmt)\n", path)
	}
	return nil
}
