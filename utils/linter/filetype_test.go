// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import "testing"

func TestFileTypeDetection(t *testing.T) {
	tests := []struct {
		path     string
		wantType FileType
		wantCC   string
	}{
		// aarch64 assembly
		{"src/spectrum4/kernel/uart.s", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/roms/cls.s", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/tests/test_cls.gen-s", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/tests/test_cls.suite", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/tests/test_cls.runner", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/targets/debug.target", FileTypeAarch64Asm, "//"},
		{"src/spectrum4/kernel/references.inc", FileTypeAarch64Asm, "//"},
		// z80 assembly
		{"src/spectrum128k/roms/rom0.s", FileTypeZ80Asm, ";"},
		{"src/spectrum128k/roms/rom1.s", FileTypeZ80Asm, ";"},
		{"src/spectrum128k/tests/lib.s", FileTypeZ80Asm, ";"},
		{"src/spectrum128k/tests/runtests.s", FileTypeZ80Asm, ";"},
		{"src/spectrum128k/tests/test_po_msg.gen-s", FileTypeZ80Asm, ";"},
		{"src/spectrum128k/tests/test_po_msg.runner", FileTypeZ80Asm, ";"},
		// shell
		{"src/spectrum4/roms/join_sources.sh", FileTypeShell, "#"},
		{"dev-setup/macOS/bootstrap.sh", FileTypeShell, "#"},
		// Go
		{"utils/linter/main.go", FileTypeGo, "//"},
		// Tup
		{"Tuprules.tup", FileTypeTup, "#"},
		{"src/spectrum4/kernel/Tupfile", FileTypeTup, "#"},
		{"Tupfile.ini", FileTypeTup, "#"},
		// markdown
		{"README.md", FileTypeMarkdown, ""},
		// yaml
		{".github/workflows/ci.yml", FileTypeYaml, "#"},
		{".markdownlint.yaml", FileTypeYaml, "#"},
		// linker script
		{"src/spectrum4/kernel/spectrum4.ld", FileTypeLinkerScript, ""},
		// go.mod
		{"utils/go.mod", FileTypeGoMod, "//"},
		// gitignore
		{".gitignore", FileTypeGitignore, "#"},
		// config.txt
		{"src/spectrum4/kernel/config.txt", FileTypeConfig, "#"},
		// Dockerfile
		{"dev-setup/docker/Dockerfile", FileTypeDockerfile, "#"},
		// blacklisted
		{"LICENCE", FileTypeBlacklist, ""},
		{"animated.gif", FileTypeBlacklist, ""},
		{"src/spectrum4/tests/tv_tuner_01.png", FileTypeBlacklist, ""},
		{"dev-setup/docker/TAG", FileTypeBlacklist, ""},
	}
	for _, tt := range tests {
		t.Run(tt.path, func(t *testing.T) {
			ft := DetectFileType(tt.path)
			if ft.Type != tt.wantType {
				t.Errorf("DetectFileType(%q) type = %v, want %v", tt.path, ft.Type, tt.wantType)
			}
			if ft.CommentChar != tt.wantCC {
				t.Errorf("DetectFileType(%q) comment = %q, want %q", tt.path, ft.CommentChar, tt.wantCC)
			}
		})
	}
}
