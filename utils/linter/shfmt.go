// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import (
	"fmt"
	"os/exec"
)

// CheckShellFormatting runs shfmt in diff mode against the file.
// Returns an error message if the file needs formatting, nil if clean.
func CheckShellFormatting(path string) error {
	cmd := exec.Command("shfmt", "-sr", "-ci", "-d", "-i", "2", path)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("shfmt: %s needs formatting:\n%s", path, string(output))
	}
	return nil
}

// FixShellFormatting runs shfmt in write mode against the file.
func FixShellFormatting(path string) error {
	cmd := exec.Command("shfmt", "-sr", "-ci", "-w", "-i", "2", path)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("shfmt: failed to format %s:\n%s", path, string(output))
	}
	return nil
}
