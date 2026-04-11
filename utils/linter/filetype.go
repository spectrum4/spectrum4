// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import (
	"path/filepath"
	"strings"
)

type FileType int

const (
	FileTypeBlacklist    FileType = iota // skip entirely
	FileTypeAarch64Asm                   // aarch64 assembly (.s, .gen-s, .suite, .runner, .target, .inc)
	FileTypeZ80Asm                       // z80 assembly (.s in spectrum128k/)
	FileTypeShell                        // shell scripts (.sh)
	FileTypeGo                           // Go source (.go)
	FileTypeTup                          // Tup build files (Tupfile, Tuprules.tup, Tupfile.ini)
	FileTypeMarkdown                     // Markdown (.md)
	FileTypeYaml                         // YAML (.yml, .yaml)
	FileTypeLinkerScript                 // Linker scripts (.ld)
	FileTypeGoMod                        // Go module files (.mod)
	FileTypeGitignore                    // .gitignore
	FileTypeConfig                       // config files (.txt)
	FileTypeDockerfile                   // Dockerfile
)

type FileInfo struct {
	Type        FileType
	CommentChar string // "" means no single-line comment syntax (e.g. markdown uses <!-- -->)
}

// blacklistExts lists file extensions that should never be linted.
var blacklistExts = map[string]bool{
	".gif": true, ".png": true, ".gz": true, ".tar": true,
	".zip": true, ".bin": true, ".elf": true, ".img": true,
	".tzx": true, ".wav": true, ".o": true,
}

// blacklistNames lists specific filenames that should never be linted.
var blacklistNames = map[string]bool{
	"LICENCE": true, "TAG": true,
}

// DetectFileType determines the file type from its repo-relative path.
func DetectFileType(path string) FileInfo {
	base := filepath.Base(path)
	ext := filepath.Ext(base)

	// Check blacklist by name
	if blacklistNames[base] {
		return FileInfo{FileTypeBlacklist, ""}
	}
	// Check blacklist by extension
	if blacklistExts[ext] {
		return FileInfo{FileTypeBlacklist, ""}
	}

	// Tup files
	if base == "Tupfile" || base == "Tuprules.tup" || base == "Tupfile.ini" {
		return FileInfo{FileTypeTup, "#"}
	}

	// Dockerfile
	if base == "Dockerfile" {
		return FileInfo{FileTypeDockerfile, "#"}
	}

	// .gitignore
	if base == ".gitignore" {
		return FileInfo{FileTypeGitignore, "#"}
	}

	// Determine z80 vs aarch64 from path
	isZ80 := strings.Contains(path, "spectrum128k/")

	switch ext {
	case ".s":
		if isZ80 {
			return FileInfo{FileTypeZ80Asm, ";"}
		}
		return FileInfo{FileTypeAarch64Asm, "//"}
	case ".sh":
		return FileInfo{FileTypeShell, "#"}
	case ".go":
		return FileInfo{FileTypeGo, "//"}
	case ".md":
		return FileInfo{FileTypeMarkdown, ""}
	case ".yml", ".yaml":
		return FileInfo{FileTypeYaml, "#"}
	case ".ld":
		return FileInfo{FileTypeLinkerScript, ""}
	case ".mod":
		return FileInfo{FileTypeGoMod, "//"}
	case ".txt":
		return FileInfo{FileTypeConfig, "#"}
	case ".inc":
		return FileInfo{FileTypeAarch64Asm, "//"}
	}

	// Handle compound extensions: .gen-s, .suite, .runner, .target
	// These don't have a standard ext, so check suffixes
	if strings.HasSuffix(base, ".gen-s") || strings.HasSuffix(base, ".suite") ||
		strings.HasSuffix(base, ".runner") || strings.HasSuffix(base, ".target") {
		if isZ80 {
			return FileInfo{FileTypeZ80Asm, ";"}
		}
		return FileInfo{FileTypeAarch64Asm, "//"}
	}

	// Unknown — treat as blacklist (exit 0, no checks)
	return FileInfo{FileTypeBlacklist, ""}
}
