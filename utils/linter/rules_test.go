// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import (
	"strings"
	"testing"
)

func yr() string { return currentYear() }

func aarch64(body string) string {
	return "# This file is part of the Spectrum +4 Project.\n" +
		"# Licencing information can be found in the LICENCE file\n" +
		"# (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n" +
		"\n" + body
}

func aarch64out(body string) string {
	// 2 blank lines before unindented content, 1 before indented
	sep := "\n"
	if len(body) > 0 && body[0] != ' ' && body[0] != '\t' {
		sep = "\n\n"
	}
	return "// This file is part of the Spectrum +4 Project.\n" +
		"// Licencing information can be found in the LICENCE file\n" +
		"// (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n" +
		sep + body
}

func z80(body string) string {
	return "; This file is part of the Spectrum +4 Project.\n" +
		"; Licencing information can be found in the LICENCE file\n" +
		"; (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n" +
		"\n" + body
}

func d78() string { return strings.Repeat("-", 78) }

// runAndJoin runs the linter on input with the given filename and returns the output.
func runAndJoin(input, filename string) string {
	ft := DetectFileType(filename)
	lines := strings.Split(input, "\n")
	l := NewLinter(lines, filename, ft)
	l.RunAll()
	return strings.Join(l.Lines, "\n")
}

// runAndErrors runs the linter and returns any errors.
func runAndErrors(input, filename string) []string {
	ft := DetectFileType(filename)
	lines := strings.Split(input, "\n")
	l := NewLinter(lines, filename, ft)
	l.RunAll()
	return l.Errors
}

func TestLinterFixes(t *testing.T) {
	tests := []struct {
		name     string
		file     string
		input    string
		expected string
	}{
		// --- Whitespace ---
		{
			name:     "trailing whitespace removed",
			file:     "test.s",
			input:    aarch64("  mov w0, #1   "),
			expected: aarch64out("  mov     w0, #1"),
		},
		{
			name:     "tabs expanded to spaces",
			file:     "test.s",
			input:    aarch64("\tmov w0, #1"),
			expected: aarch64out("    mov     w0, #1"),
		},

		// --- Copyright ---
		{
			name:     "copyright year fixed",
			file:     "test.s",
			input:    "# This file is part of the Spectrum +4 Project.\n# Licencing information can be found in the LICENCE file\n# (C) 2021-2020 Spectrum +4 Authors. All rights reserved.\n\n.text",
			expected: aarch64out(".text"),
		},
		{
			name:     "copyright injected when missing",
			file:     "test.s",
			input:    ".text\n  mov w0, #1",
			expected: aarch64out(".text\n  mov     w0, #1"),
		},
		{
			name:     "z80 copyright year fixed",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    "; This file is part of the Spectrum +4 Project.\n; Licencing information can be found in the LICENCE file\n; (C) 2021-2020 Spectrum +4 Authors. All rights reserved.\n\n",
			expected: z80(""),
		},
		{
			name:     "z80 hash copyright converted to semicolon",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    "# This file is part of the Spectrum +4 Project.\n# Licencing information can be found in the LICENCE file\n# (C) 2021 Spectrum +4 Authors. All rights reserved.\n\n        ld      a, b",
			expected: z80("  ld      a, b"),
		},
		{
			name:     "copyright preserved after shebang",
			file:     "test.sh",
			input:    "#!/usr/bin/env bash\n\n# This file is part of the Spectrum +4 Project.\n# Licencing information can be found in the LICENCE file\n# (C) 2021-2025 Spectrum +4 Authors. All rights reserved.\n\necho hello",
			expected: "#!/usr/bin/env bash\n\n" + aarch64("echo hello"),
		},
		{
			name:     "copyright preserved after dockerfile syntax",
			file:     "Dockerfile",
			input:    "# syntax=docker/dockerfile:1.3\n\n# This file is part of the Spectrum +4 Project.\n# Licencing information can be found in the LICENCE file\n# (C) 2021-2025 Spectrum +4 Authors. All rights reserved.\n\nFROM ubuntu",
			expected: "# syntax=docker/dockerfile:1.3\n\n" + aarch64("FROM ubuntu"),
		},
		{
			name:     "markdown copyright injected",
			file:     "README.md",
			input:    "# My Title\n\nSome content.",
			expected: "<!--\nThis file is part of the Spectrum +4 Project.\nLicencing information can be found in the LICENCE file\n(C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n-->\n\n# My Title\n\nSome content.",
		},
		{
			name:     "markdown copyright year fixed",
			file:     "README.md",
			input:    "<!--\nThis file is part of the Spectrum +4 Project.\nLicencing information can be found in the LICENCE file\n(C) 2021-2025 Spectrum +4 Authors. All rights reserved.\n-->\n\n# Title",
			expected: "<!--\nThis file is part of the Spectrum +4 Project.\nLicencing information can be found in the LICENCE file\n(C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n-->\n\n# Title",
		},

		// --- .L labels ---
		{
			name:     "dot-L label stripped",
			file:     "test.s",
			input:    aarch64(".Lmy_label:\n  ret"),
			expected: aarch64out("// " + d78() + "\n// TODO: Description\n// " + d78() + "\n// On entry:\n//   TODO\n// On exit:\n//   TODO\nmy_label:\n  ret"),
		},
		{
			name:     "dot-L references updated",
			file:     "test.s",
			input:    aarch64(".Lloop:\n  b       .Lloop"),
			expected: aarch64out("// " + d78() + "\n// TODO: Description\n// " + d78() + "\n// On entry:\n//   TODO\n// On exit:\n//   TODO\nloop:\n  b       loop"),
		},

		// --- Hex conversion (Z80 only) ---
		{
			name:     "dollar hex converted to 0x",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, $FF"),
			expected: z80("  ld      a, 0xff"),
		},
		{
			name:     "dollar hex multi-digit",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      hl, $4000"),
			expected: z80("  ld      hl, 0x4000"),
		},
		{
			name:     "hex modified in aarch64",
			file:     "test.s",
			input:    aarch64("  mov     w0, #0x1C300000"),
			expected: aarch64out("  mov     w0, #0x1c300000"),
		},
		{
			name:     "z80 hex lowercased",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, 0xFF"),
			expected: z80("  ld      a, 0xff"),
		},
		{
			name:     "non-hex text preserved",
			file:     "test.s",
			input:    aarch64("  adr     x0, msg_HELLO"),
			expected: aarch64out("  adr     x0, msg_HELLO"),
		},

		// --- Binary prefix (Z80 only) ---
		{
			name:     "percent binary converted to 0b",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, %01010101"),
			expected: z80("  ld      a, 0b01010101"),
		},
		{
			name:     "multiple percent binary converted",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, %11110000 | %00001111"),
			expected: z80("  ld      a, 0b11110000 | 0b00001111"),
		},
		{
			name:     "percent modulus preserved in aarch64",
			file:     "test.s",
			input:    aarch64("  // address = (x11/2)%108"),
			expected: aarch64out("  // address = (x11/2)%108"),
		},

		// --- Instruction case ---
		{
			name:     "aarch64 instruction lowercased",
			file:     "test.s",
			input:    aarch64("  MOV     w0, #1"),
			expected: aarch64out("  mov     w0, #1"),
		},
		{
			name:     "z80 instruction lowercased",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        LD      a, b"),
			expected: z80("  ld      a, b"),
		},
		{
			name:     "z80 lowercase instruction unchanged",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, b"),
			expected: z80("  ld      a, b"),
		},

		// --- Z80 register/condition code case ---
		{
			name:     "z80 conditional return lowercased",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        RET     Z\n        RET     C"),
			expected: z80("  ret     z\n  ret     c"),
		},

		// --- Z80 ROM indentation ---
		{
			name:     "z80 rom 8-space instruction indent normalised to 2",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ld      a, b"),
			expected: z80("  ld      a, b"),
		},
		{
			name:     "z80 rom directive indent normalised",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        .byte 0x00, 0x00"),
			expected: z80("  .byte 0x00, 0x00"),
		},
		{
			name:     "z80 rom 2-space indent unchanged",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("  ld      a, b"),
			expected: z80("  ld      a, b"),
		},
		{
			name:     "z80 rom shallow comment-only line pulled to col 2",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("        ;;; Block comment at col 8"),
			expected: z80("  ;;; Block comment at col 8"),
		},
		{
			name:     "z80 rom comment-only at col 42 preserved",
			file:     "src/spectrum128k/roms/rom0.s",
			input:    z80("                                                  ; continuation"),
			expected: z80("                                                  ; continuation"),
		},
		{
			name:     "z80 non-rom nested indent preserved",
			file:     "src/spectrum128k/tests/runtests.s",
			input:    z80("outer:\n  call    foo\n    inner:\n      ld      a, b"),
			expected: z80("outer:\n  call    foo\n    inner:\n      ld      a, b"),
		},

		// --- Comma spacing ---
		{
			name:     "directive comma spacing preserved",
			file:     "test.s",
			input:    aarch64(".set C_FLAG,    0b00000001\n.set PV_FLAG,   0b00000100"),
			expected: aarch64out(".set C_FLAG,    0b00000001\n.set PV_FLAG,   0b00000100"),
		},
		{
			name:     "instruction comma spacing fixed",
			file:     "test.s",
			input:    aarch64("  mov     w0,  w1"),
			expected: aarch64out("  mov     w0, w1"),
		},

		// --- Routine spacing ---
		{
			name: "two blank lines before routine header",
			file: "test.s",
			input: aarch64(
				"# " + d78() + "\n# foo\n# " + d78() + "\n# On entry:\n#   none\n# On exit:\n#   none\nfoo:\n  ret\n\n" +
					"# ---\n# bar\n# ---\n# On entry:\n#   none\n# On exit:\n#   none\nbar:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// foo\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nfoo:\n  ret\n\n\n" +
					"// " + d78() + "\n// bar\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nbar:\n  ret"),
		},
		{
			name: "three blank lines reduced to two",
			file: "test.s",
			input: aarch64(
				"# " + d78() + "\n# foo\n# " + d78() + "\n# On entry:\n#   none\n# On exit:\n#   none\nfoo:\n  ret\n\n\n\n" +
					"# ---\n# bar\n# ---\n# On entry:\n#   none\n# On exit:\n#   none\nbar:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// foo\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nfoo:\n  ret\n\n\n" +
					"// " + d78() + "\n// bar\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nbar:\n  ret"),
		},

		{
			name: "multiple blank lines within routine collapsed to one",
			file: "test.s",
			input: aarch64(
				"# " + d78() + "\n# foo\n# " + d78() + "\n# On entry:\n#   none\n# On exit:\n#   none\nfoo:\n  mov     w0, #1\n\n\n\n  mov     w1, #2\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// foo\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nfoo:\n  mov     w0, #1\n\n  mov     w1, #2\n  ret"),
		},
		{
			name: "two blank lines before label within routine preserved",
			file: "test.s",
			input: aarch64(
				"# " + d78() + "\n# foo\n# " + d78() + "\n# On entry:\n#   none\n# On exit:\n#   none\nfoo:\n  mov     w0, #1\n\n\n\nbar:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// foo\n// " + d78() + "\n// On entry:\n//   none\n// On exit:\n//   none\nfoo:\n  mov     w0, #1\n\n\n" +
					"// " + d78() + "\n// TODO: Description\n// " + d78() + "\n// On entry:\n//   TODO\n// On exit:\n//   TODO\nbar:\n  ret"),
		},

		// --- Routine headers ---
		{
			name:  "routine header injected when missing",
			file:  "test.s",
			input: aarch64("my_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// TODO: Description\n// " + d78() + "\n// On entry:\n//   TODO\n// On exit:\n//   TODO\nmy_routine:\n  ret"),
		},
		{
			name:  "existing comment used as description",
			file:  "test.s",
			input: aarch64("# Copy default CHANS to heap\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// Copy default CHANS to heap\n// " + d78() + "\n// On entry:\n//   TODO\n// On exit:\n//   TODO\nmy_routine:\n  ret"),
		},
		{
			name:  "short dashes standardised to 78",
			file:  "test.s",
			input: aarch64("# ---\n# My routine\n# ---\n# On entry:\n#   w0 = value\n# On exit:\n#   w0 = result\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// My routine\n// " + d78() + "\n// On entry:\n//   w0 = value\n// On exit:\n//   w0 = result\nmy_routine:\n  ret"),
		},
		{
			name:  "missing On exit injected",
			file:  "test.s",
			input: aarch64("# ----------\n# My routine\n# ----------\n# On entry:\n#   w0 = value\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// My routine\n// " + d78() + "\n// On entry:\n//   w0 = value\n// On exit:\n//   TODO\nmy_routine:\n  ret"),
		},
		{
			name:     "data label skipped",
			file:     "test.s",
			input:    aarch64("my_data:\n  .byte 0x01, 0x02"),
			expected: aarch64out("my_data:\n  .byte 0x01, 0x02"),
		},
		{
			name: "complete routine header preserved",
			file: "test.s",
			input: aarch64(
				"# " + d78() + "\n# My routine\n# " + d78() + "\n# On entry:\n#   w0 = value\n# On exit:\n#   w0 = result\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// My routine\n// " + d78() + "\n// On entry:\n//   w0 = value\n// On exit:\n//   w0 = result\nmy_routine:\n  ret"),
		},
		{
			name: "blank comment lines trimmed from description",
			file: "test.s",
			input: aarch64(
				"# ---\n#\n# My routine\n#\n# ---\n# On entry:\n#   w0 = value\n# On exit:\n#   w0 = result\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// My routine\n// " + d78() + "\n// On entry:\n//   w0 = value\n// On exit:\n//   w0 = result\nmy_routine:\n  ret"),
		},
		{
			name: "blank comment lines trimmed from On entry and On exit",
			file: "test.s",
			input: aarch64(
				"# ---\n# My routine\n# ---\n# On entry:\n#\n#   w0 = value\n#\n# On exit:\n#\n#   w0 = result\n#\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// My routine\n// " + d78() + "\n// On entry:\n//   w0 = value\n// On exit:\n//   w0 = result\nmy_routine:\n  ret"),
		},
		{
			name: "multiple On entry/On exit sections preserved verbatim",
			file: "test.s",
			input: aarch64(
				"# ---\n# Fetch position\n# ---\n# Description text.\n#\n# If case A:\n#   On entry:\n#     w0 = value A\n#   On exit:\n#     w1 = result A\n#\n# If case B:\n#   On entry:\n#     w0 = value B\n#   On exit:\n#     w1 = result B\nmy_routine:\n  ret"),
			expected: aarch64out(
				"// " + d78() + "\n// Fetch position\n// Description text.\n//\n// If case A:\n// " + d78() + "\n//   On entry:\n//     w0 = value A\n//   On exit:\n//     w1 = result A\n//\n// If case B:\n//   On entry:\n//     w0 = value B\n//   On exit:\n//     w1 = result B\nmy_routine:\n  ret"),
		},

		// --- .if/.endif transparency ---
		{
			name:     "data label with .if block not treated as routine",
			file:     "test.s",
			input:    aarch64("my_data_END:\n.if UART_DEBUG\n  .space 4\n.endif"),
			expected: aarch64out("my_data_END:\n.if UART_DEBUG\n  .space 4\n.endif"),
		},
		{
			name:     "data directive inside .if .else recognised",
			file:     "test.s",
			input:    aarch64("my_table:\n.if FOO\n  .byte 0x01\n.else\n  .byte 0x02\n.endif"),
			expected: aarch64out("my_table:\n.if FOO\n  .byte 0x01\n.else\n  .byte 0x02\n.endif"),
		},

		// --- Linker script copyright ---
		{
			name:     "linker script block comment copyright preserved",
			file:     "src/spectrum4/kernel/spectrum4.ld",
			input:    "/*\n * spectrum4.ld\n *\n * This file is part of the Spectrum +4 Project.\n * Licencing information can be found in the LICENCE file\n * (C) 2021 Spectrum +4 Authors. All rights reserved.\n */",
			expected: "/*\n * spectrum4.ld\n *\n * This file is part of the Spectrum +4 Project.\n * Licencing information can be found in the LICENCE file\n * (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n */",
		},
		{
			name:     "linker script block comment copyright year updated",
			file:     "src/spectrum4/kernel/spectrum4.ld",
			input:    "/*\n * This file is part of the Spectrum +4 Project.\n * (C) 2021-2025 Spectrum +4 Authors. All rights reserved.\n */",
			expected: "/*\n * This file is part of the Spectrum +4 Project.\n * (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n */",
		},
		{
			name:     "linker script copyright injected as block comment",
			file:     "src/spectrum4/kernel/spectrum4.ld",
			input:    "ENTRY(_start)\n\nSECTIONS\n{",
			expected: "/*\n * This file is part of the Spectrum +4 Project.\n * Licencing information can be found in the LICENCE file\n * (C) 2021-" + yr() + " Spectrum +4 Authors. All rights reserved.\n */\n\nENTRY(_start)\n\nSECTIONS\n{",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := runAndJoin(tt.input, tt.file)
			if got != tt.expected {
				t.Errorf("mismatch\n--- got ---\n%s\n--- expected ---\n%s", got, tt.expected)
			}
		})
	}
}

func TestLinterErrors(t *testing.T) {
	tests := []struct {
		name      string
		file      string
		input     string
		wantNoErr bool // true = expect no errors containing "label"
	}{
		{
			name:      "CamelCase label OK",
			file:      "test.s",
			input:     aarch64("MyRoutine:\n  ret"),
			wantNoErr: true,
		},
		{
			name:      "mixed case label OK",
			file:      "src/spectrum4/roms/bss.s",
			input:     aarch64("transfer_ring_slot1_EP0:\n  .byte 0x00"),
			wantNoErr: true,
		},
		{
			name:      "all uppercase label OK",
			file:      "src/spectrum4/roms/bss.s",
			input:     aarch64("TSTACK_LO:\n  .byte 0x00"),
			wantNoErr: true,
		},
		{
			name:      "snake_case label OK",
			file:      "test.s",
			input:     aarch64("# " + d78() + "\n# My routine\n# " + d78() + "\n# On entry:\n#   none\n# On exit:\n#   none\nmy_routine:\n  ret"),
			wantNoErr: true,
		},
		{
			name:      "numeric label OK",
			file:      "test.s",
			input:     aarch64("  1:\n    ret"),
			wantNoErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			errs := runAndErrors(tt.input, tt.file)
			hasLabelErr := false
			for _, e := range errs {
				if strings.Contains(e, "label") {
					hasLabelErr = true
				}
			}
			if tt.wantNoErr && hasLabelErr {
				t.Errorf("unexpected label error: %v", errs)
			}
		})
	}
}
