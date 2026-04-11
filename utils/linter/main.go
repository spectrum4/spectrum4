// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

// try this

package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

// repoRelativePath returns the repo-relative path for file type detection.
// If the given path is relative, it prepends the CWD relative to the repo root.
func repoRelativePath(path string) string {
	if filepath.IsAbs(path) {
		return path
	}
	cwd, err := os.Getwd()
	if err != nil {
		return path
	}
	// Walk up to find the repo root (directory containing .git)
	dir := cwd
	for {
		if _, err := os.Stat(filepath.Join(dir, ".git")); err == nil {
			rel, err := filepath.Rel(dir, filepath.Join(cwd, path))
			if err != nil {
				return path
			}
			return rel
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return path
		}
		dir = parent
	}
}

func main() {
	if len(os.Args) < 3 {
		log.Fatal("usage: linter <check|fix> <path>")
	}
	mode := os.Args[1]
	path := os.Args[2]

	ft := DetectFileType(repoRelativePath(path))
	if ft.Type == FileTypeBlacklist {
		os.Exit(0)
	}

	// Shell files: delegate formatting to shfmt, still run copyright check.
	if ft.Type == FileTypeShell {
		switch mode {
		case "check":
			if err := CheckShellFormatting(path); err != nil {
				log.Print(err)
				os.Exit(1)
			}
		case "fix":
			if err := FixShellFormatting(path); err != nil {
				log.Print(err)
				os.Exit(1)
			}
		default:
			log.Fatalf("unknown mode: %s (expected check or fix)", mode)
		}
		// Still run copyright check on shell files via the normal path below.
	}

	// Go files: delegate formatting to gofmt, still run copyright check.
	if ft.Type == FileTypeGo {
		switch mode {
		case "check":
			if err := CheckGoFormatting(path); err != nil {
				log.Print(err)
				os.Exit(1)
			}
		case "fix":
			if err := FixGoFormatting(path); err != nil {
				log.Print(err)
				os.Exit(1)
			}
		default:
			log.Fatalf("unknown mode: %s (expected check or fix)", mode)
		}
		// Still run copyright check on Go files via the normal path below.
	}

	info, err := os.Stat(path)
	if err != nil {
		log.Fatalf("cannot stat %s: %v", path, err)
	}
	fileMode := info.Mode()

	data, err := os.ReadFile(path)
	if err != nil {
		log.Fatalf("cannot read %s: %v", path, err)
	}

	content := string(data)
	// Normalise line endings and split
	content = strings.ReplaceAll(content, "\r\n", "\n")
	lines := strings.Split(strings.TrimRight(content, "\n"), "\n")

	original := make([]string, len(lines))
	copy(original, lines)

	linter := NewLinter(lines, path, ft)
	linter.RunAll()

	switch mode {
	case "check":
		needsFormat := false
		if len(linter.Lines) != len(original) {
			needsFormat = true
		} else {
			for i, line := range linter.Lines {
				if line != original[i] {
					needsFormat = true
					break
				}
			}
		}
		if needsFormat {
			fmt.Fprintf(os.Stderr, "%s: needs formatting\n", path)
		}
		linter.PrintErrors()
		if needsFormat || linter.HasErrors() {
			os.Exit(1)
		}

	case "fix":
		// Only write if content actually changed
		out := strings.Join(linter.Lines, "\n") + "\n"
		if out != string(data) {
			if err := os.WriteFile(path, []byte(out), fileMode.Perm()); err != nil {
				log.Fatalf("cannot write %s: %v", path, err)
			}
			fmt.Printf("%s: fixed\n", path)
		}
		linter.PrintErrors()
		if linter.HasErrors() {
			os.Exit(1)
		}

	default:
		log.Fatalf("unknown mode: %s (expected check or fix)", mode)
	}
}
