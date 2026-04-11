// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
	"time"
	"unicode"
)

// Linter holds state for a single file being processed.
type Linter struct {
	FileInfo FileInfo
	Filename string // for error reporting
	Lines    []string
	Errors   []string
}

// NewLinter creates a linter for the given file content.
func NewLinter(lines []string, filename string, fi FileInfo) *Linter {
	return &Linter{
		FileInfo: fi,
		Filename: filename,
		Lines:    lines,
	}
}

// Error records a non-fixable violation. The linter will exit non-zero.
func (l *Linter) Error(lineNum int, msg string) {
	l.Errors = append(l.Errors, fmt.Sprintf("%s:%d: %s", l.Filename, lineNum, msg))
}

// PrintErrors writes all errors to stderr.
func (l *Linter) PrintErrors() {
	for _, e := range l.Errors {
		fmt.Fprintln(os.Stderr, e)
	}
}

// HasErrors returns true if any non-fixable violations were found.
func (l *Linter) HasErrors() bool {
	return len(l.Errors) > 0
}

// commentChar returns the single-line comment character for the file.
func (l *Linter) commentChar() string {
	return l.FileInfo.CommentChar
}

// currentYear returns the current calendar year as a string.
func currentYear() string {
	return fmt.Sprintf("%d", time.Now().Year())
}

// copyrightLines returns the expected 3-line copyright block for the given comment char.
func copyrightLines(cc string) [3]string {
	year := currentYear()
	return [3]string{
		cc + " This file is part of the Spectrum +4 Project.",
		cc + " Licencing information can be found in the LICENCE file",
		cc + " (C) 2021-" + year + " Spectrum +4 Authors. All rights reserved.",
	}
}

// preambleCount returns the number of lines to skip before the copyright block.
// Shebang (#!/...) and Dockerfile syntax directives (# syntax=) are preambles.
func preambleCount(lines []string) int {
	if len(lines) == 0 {
		return 0
	}
	first := lines[0]
	if strings.HasPrefix(first, "#!") || strings.HasPrefix(first, "# syntax=") {
		// Preamble line followed by a blank line
		if len(lines) > 1 && lines[1] == "" {
			return 2
		}
		return 1
	}
	return 0
}

// FixHashComments replaces # line comments with ; in Z80 assembly files.
// In Z80 assembly (GNU as syntax), ; is the standard comment character.
func (l *Linter) FixHashComments() {
	cc := l.commentChar()
	for i, line := range l.Lines {
		trimmed := strings.TrimLeft(line, " \t")
		if strings.HasPrefix(trimmed, "# ") || trimmed == "#" {
			idx := strings.Index(line, "#")
			l.Lines[i] = line[:idx] + cc + line[idx+1:]
		}
	}
}

// FixCopyright checks and fixes the 3-line copyright header.
// If missing, injects the correct header. Handles shebang/syntax preambles
// and markdown <!-- --> comment style.
func (l *Linter) FixCopyright() {
	if l.FileInfo.Type == FileTypeMarkdown {
		l.fixMarkdownCopyright()
		return
	}
	if l.FileInfo.Type == FileTypeLinkerScript {
		l.fixBlockCommentCopyright()
		return
	}
	cc := l.commentChar()
	if cc == "" {
		return
	}

	expected := copyrightLines(cc)
	skip := preambleCount(l.Lines)

	// Check if first non-preamble line looks like a copyright header
	if len(l.Lines) >= skip+3 && strings.HasPrefix(l.Lines[skip], cc+" This file is part of the Spectrum") {
		// Present — fix if needed
		for i := 0; i < 3; i++ {
			if l.Lines[skip+i] != expected[i] {
				l.Lines[skip+i] = expected[i]
			}
		}
		return
	}

	// Missing — inject copyright header after preamble
	header := []string{expected[0], expected[1], expected[2], ""}
	newLines := make([]string, 0, len(l.Lines)+len(header))
	newLines = append(newLines, l.Lines[:skip]...)
	newLines = append(newLines, header...)
	newLines = append(newLines, l.Lines[skip:]...)
	l.Lines = newLines
}

// fixMarkdownCopyright checks and fixes markdown copyright using a multi-line
// <!-- ... --> block.
func (l *Linter) fixMarkdownCopyright() {
	year := currentYear()
	expected := [5]string{
		"<!--",
		"This file is part of the Spectrum +4 Project.",
		"Licencing information can be found in the LICENCE file",
		"(C) 2021-" + year + " Spectrum +4 Authors. All rights reserved.",
		"-->",
	}

	if len(l.Lines) < 5 || l.Lines[0] != "<!--" {
		// Missing — inject copyright header
		header := []string{expected[0], expected[1], expected[2], expected[3], expected[4], ""}
		newLines := make([]string, 0, len(l.Lines)+len(header))
		newLines = append(newLines, header...)
		newLines = append(newLines, l.Lines...)
		l.Lines = newLines
		return
	}
	// Present — fix content if needed
	for i := 0; i < 5; i++ {
		if l.Lines[i] != expected[i] {
			l.Lines[i] = expected[i]
		}
	}
}

// fixBlockCommentCopyright handles copyright for block-comment languages (e.g. /* */ for linker scripts).
// It detects copyright in both standalone `/* text */` lines and inside multi-line `/* ... */` blocks.
func (l *Linter) fixBlockCommentCopyright() {
	year := currentYear()

	// Scan the first 15 lines for an existing copyright (may be inside a block comment).
	for i := 0; i < len(l.Lines) && i < 15; i++ {
		if !strings.Contains(l.Lines[i], "This file is part of the Spectrum") {
			continue
		}
		// Found — update the (C) year line nearby.
		for j := i; j < len(l.Lines) && j < i+5; j++ {
			if strings.Contains(l.Lines[j], "(C) 2021") && strings.Contains(l.Lines[j], "Spectrum +4 Authors") {
				updated := regexp.MustCompile(`\(C\) 2021(-\d+)?`).ReplaceAllString(l.Lines[j], "(C) 2021-"+year)
				if l.Lines[j] != updated {
					l.Lines[j] = updated
				}
				return
			}
		}
		return
	}

	// Missing — inject copyright as a multi-line block comment.
	header := []string{
		"/*",
		" * This file is part of the Spectrum +4 Project.",
		" * Licencing information can be found in the LICENCE file",
		" * (C) 2021-" + year + " Spectrum +4 Authors. All rights reserved.",
		" */",
		"",
	}
	newLines := make([]string, 0, len(l.Lines)+len(header))
	newLines = append(newLines, header...)
	newLines = append(newLines, l.Lines...)
	l.Lines = newLines
}

var hexPattern = regexp.MustCompile(`0x[0-9a-fA-F]+`)
var dollarHexPattern = regexp.MustCompile(`\$([0-9a-fA-F]+)`)
var percentBinaryPattern = regexp.MustCompile(`%([01]+)\b`)
var globalLabelValid = regexp.MustCompile(`^[a-zA-Z_][a-zA-Z0-9_]*:`)

// FixHexCase lowercases all hex digits in 0x... patterns and
// converts $FF style hex (z80 convention) to 0xff style.
func (l *Linter) FixHexCase() {
	for i, line := range l.Lines {
		// Convert $FF → 0xff
		line = dollarHexPattern.ReplaceAllStringFunc(line, func(s string) string {
			return "0x" + strings.ToLower(s[1:])
		})
		// Lowercase 0xFF → 0xff
		line = hexPattern.ReplaceAllStringFunc(line, strings.ToLower)
		l.Lines[i] = line
	}
}

// FixBinaryPrefix converts %01010101 style binary (z80 convention) to 0b01010101 style.
func (l *Linter) FixBinaryPrefix() {
	for i, line := range l.Lines {
		l.Lines[i] = percentBinaryPattern.ReplaceAllString(line, "0b${1}")
	}
}

// FixDotLLabels strips the .L prefix from label definitions and all references.
func (l *Linter) FixDotLLabels() {
	// Collect all .L labels defined in this file
	labels := map[string]bool{}
	for _, line := range l.Lines {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, ".L") {
			if idx := strings.Index(trimmed, ":"); idx > 0 {
				labels[trimmed[:idx]] = true
			}
		}
	}
	if len(labels) == 0 {
		return
	}
	// Replace all occurrences of each .L label with the stripped version
	for label := range labels {
		stripped := label[2:] // remove ".L" prefix
		for i, line := range l.Lines {
			l.Lines[i] = strings.ReplaceAll(line, label, stripped)
		}
	}
}

// CheckLabels verifies all labels follow naming conventions:
// - Column 0: snake_case (any case combination)
// - Indented: numeric only (1:, 2:, etc.)
func (l *Linter) CheckLabels() {
	for i, line := range l.Lines {
		trimmed := strings.TrimSpace(line)
		// Skip empty lines, comments, directives, macro bodies (but not .L labels)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") || strings.HasPrefix(trimmed, ";") ||
			strings.HasPrefix(trimmed, "//") || strings.Contains(trimmed, "\\") {
			continue
		}
		// Skip assembler directives (.text, .align, .byte, etc.) but not .L labels
		if strings.HasPrefix(trimmed, ".") && !strings.HasPrefix(trimmed, ".L") {
			continue
		}
		// Must contain a colon to be a label candidate
		colonIdx := strings.Index(trimmed, ":")
		if colonIdx < 0 {
			continue
		}
		labelPart := trimmed[:colonIdx]
		// Skip lines where colon is in an operand, not a label (e.g. has spaces, commas, brackets before colon)
		if strings.ContainsAny(labelPart, " ,[]#") {
			continue
		}

		// Check if at column 0 (global label)
		if len(line) > 0 && line[0] != ' ' && line[0] != '\t' {
			if globalLabelValid.MatchString(line) {
				continue // valid global label
			}
			// Numeric labels at column 0 are valid
			isNumeric := true
			for _, c := range labelPart {
				if c < '0' || c > '9' {
					isNumeric = false
					break
				}
			}
			if isNumeric {
				continue
			}
			l.Error(i+1, fmt.Sprintf("global label must be snake_case: %s", labelPart))
			continue
		}

		// Indented label — accept any valid identifier or numeric label
	}
}

// FixRoutineSpacing normalises blank lines in assembly files:
//   - Exactly 2 blank lines between routines (detected as blank lines
//     followed by a routine header comment block or global label).
//   - At most 1 blank line within a routine (after the first routine starts).
//   - Blank lines before the first routine are left unchanged.
func (l *Linter) FixRoutineSpacing() {
	if l.FileInfo.Type != FileTypeAarch64Asm {
		return
	}
	var result []string
	i := 0
	for i < len(l.Lines) {
		trimmed := strings.TrimSpace(l.Lines[i])

		if trimmed == "" {
			count := 0
			for i < len(l.Lines) && strings.TrimSpace(l.Lines[i]) == "" {
				count++
				i++
			}

			nextIsUnindented := i < len(l.Lines) && len(l.Lines[i]) > 0 &&
				l.Lines[i][0] != ' ' && l.Lines[i][0] != '\t'

			if nextIsUnindented {
				// Before unindented lines: exactly 2
				result = append(result, "", "")
			} else if count > 1 {
				// Before indented lines: cap at 1
				result = append(result, "")
			} else {
				result = append(result, "")
			}
			continue
		}

		result = append(result, l.Lines[i])
		i++
	}
	l.Lines = result
}

var instructionPattern = regexp.MustCompile(`^\s{2,}([a-zA-Z][a-zA-Z0-9_.]*)\s`)
var labelThenInstructionPattern = regexp.MustCompile(`^[a-zA-Z_][a-zA-Z0-9_]*:\s+([a-zA-Z][a-zA-Z0-9_.]*)\s`)

// labelInstructionPattern matches a label followed by an instruction on the same line.
// e.g. "L000C:  DEFB $00, $00   ; comment"
var labelInstructionPattern = regexp.MustCompile(`^([a-zA-Z_][a-zA-Z0-9_]*:)\s+(\S.*)$`)

// SplitLabelLines splits lines that have both a label and an instruction onto separate lines.
func (l *Linter) SplitLabelLines() {
	var result []string
	for _, line := range l.Lines {
		trimmed := strings.TrimSpace(line)
		m := labelInstructionPattern.FindStringSubmatch(trimmed)
		if m != nil {
			label := m[1]
			rest := m[2]
			// Only split if the rest looks like an instruction or directive, not just a comment
			restTrimmed := strings.TrimSpace(rest)
			if restTrimmed != "" && !strings.HasPrefix(restTrimmed, "#") &&
				!strings.HasPrefix(restTrimmed, ";") && !strings.HasPrefix(restTrimmed, "//") {
				result = append(result, label)
				result = append(result, "  "+rest)
				continue
			}
		}
		result = append(result, line)
	}
	l.Lines = result
}

// FixInstructionCase lowercases instruction mnemonics.
func (l *Linter) FixInstructionCase() {
	for i, line := range l.Lines {
		// Try indented instruction first, then label+instruction
		m := instructionPattern.FindStringSubmatch(line)
		if m == nil {
			m = labelThenInstructionPattern.FindStringSubmatch(line)
		}
		if m == nil {
			continue
		}
		mnemonic := m[1]
		// Skip directives (start with .)
		if strings.HasPrefix(mnemonic, ".") {
			continue
		}
		lower := strings.ToLower(mnemonic)
		if mnemonic != lower {
			l.Lines[i] = strings.Replace(line, mnemonic, lower, 1)
		}
	}
}

// FixDirectiveNames replaces Z80-style data directives with GNU as equivalents:
// defb → .byte, defw → .word, defm → .ascii.
// Must run after FixInstructionCase (which lowercases DEFB → defb).
func (l *Linter) FixDirectiveNames() {
	replacements := map[string]string{
		"defb": ".byte",
		"defw": ".word",
		"defm": ".ascii",
	}
	for i, line := range l.Lines {
		m := instructionPattern.FindStringSubmatchIndex(line)
		if m == nil {
			m = labelThenInstructionPattern.FindStringSubmatchIndex(line)
		}
		if m == nil {
			continue
		}
		mnemonic := line[m[2]:m[3]]
		if repl, ok := replacements[mnemonic]; ok {
			l.Lines[i] = line[:m[2]] + repl + line[m[3]:]
		}
	}
}

// FixCommaSpacing ensures exactly one space follows each comma in instruction
// operands. Commas inside quoted literals and comments are left alone.
func (l *Linter) FixCommaSpacing() {
	for i, line := range l.Lines {
		// Only fix comma spacing in instruction operands, not directives or other lines.
		m := instructionPattern.FindStringSubmatch(line)
		if m == nil {
			m = labelThenInstructionPattern.FindStringSubmatch(line)
		}
		if m == nil || strings.HasPrefix(m[1], ".") {
			continue
		}

		// Find comment start: ";" for Z80, "//" for aarch64.
		// Cannot use "#" for aarch64 since it's also the immediate prefix.
		commentIdx := len(line)
		if idx := strings.Index(line, ";"); idx >= 0 {
			commentIdx = idx
		}
		if idx := strings.Index(line, "//"); idx >= 0 && idx < commentIdx {
			commentIdx = idx
		}
		operand := line[:commentIdx]
		comment := line[commentIdx:]

		var result strings.Builder
		j := 0
		for j < len(operand) {
			if operand[j] == '\'' || operand[j] == '"' {
				quote := operand[j]
				result.WriteByte(quote)
				j++
				for j < len(operand) && operand[j] != quote {
					result.WriteByte(operand[j])
					j++
				}
				if j < len(operand) {
					result.WriteByte(operand[j])
					j++
				}
			} else if operand[j] == ',' {
				result.WriteByte(',')
				j++
				// Skip any existing spaces
				for j < len(operand) && operand[j] == ' ' {
					j++
				}
				// Add exactly one space (unless at end of operand)
				if j < len(operand) {
					result.WriteByte(' ')
				}
			} else {
				result.WriteByte(operand[j])
				j++
			}
		}
		l.Lines[i] = result.String() + comment
	}
}

// z80OperandPattern matches Z80 register names and condition codes in instruction
// operands. Shadow registers (AF' etc.) have no trailing \b since ' is non-word.
// Longer patterns listed first so alternation prefers them.
var z80OperandPattern = regexp.MustCompile(
	`\b(?:AF'|BC'|DE'|HL')` +
		`|\b(?:IXH|IXL|IYH|IYL|AF|BC|DE|HL|SP|IX|IY)\b` +
		`|\b(?:NZ|NC|PE|PO|[ABCDEFHILMPRZ])\b`,
)

// replaceOutsideQuotes applies a function to regex matches in s, skipping
// content inside quoted literals ('X' single-char and "..." double-quoted).
func replaceOutsideQuotes(s string, re *regexp.Regexp, fn func(string) string) string {
	var result strings.Builder
	i := 0
	for i < len(s) {
		if s[i] == '"' {
			result.WriteByte('"')
			i++
			for i < len(s) && s[i] != '"' {
				result.WriteByte(s[i])
				i++
			}
			if i < len(s) {
				result.WriteByte(s[i])
				i++
			}
		} else if s[i] == '\'' && i+2 < len(s) && s[i+2] == '\'' {
			result.WriteByte(s[i])
			result.WriteByte(s[i+1])
			result.WriteByte(s[i+2])
			i += 3
		} else {
			j := i
			for j < len(s) {
				if s[j] == '"' {
					break
				}
				if s[j] == '\'' && j+2 < len(s) && s[j+2] == '\'' {
					break
				}
				j++
			}
			result.WriteString(re.ReplaceAllStringFunc(s[i:j], fn))
			i = j
		}
	}
	return result.String()
}

// FixRegisterCase lowercases Z80 register names in instruction operands only.
// Comments and non-instruction lines are left untouched.
func (l *Linter) FixRegisterCase() {
	cc := l.commentChar()
	for i, line := range l.Lines {
		// Only process lines with instructions
		m := instructionPattern.FindStringSubmatchIndex(line)
		if m == nil {
			m = labelThenInstructionPattern.FindStringSubmatchIndex(line)
		}
		if m == nil {
			continue
		}
		mnemonic := line[m[2]:m[3]]
		// Skip directives
		if strings.HasPrefix(mnemonic, ".") {
			continue
		}

		// Extract the operand portion: after the mnemonic match, before comment
		operandStart := m[3]
		commentIdx := len(line)
		if cc != "" {
			if idx := strings.Index(line[operandStart:], cc); idx >= 0 {
				commentIdx = operandStart + idx
			}
		}

		prefix := line[:operandStart]
		operand := line[operandStart:commentIdx]
		comment := line[commentIdx:]

		operand = replaceOutsideQuotes(operand, z80OperandPattern, strings.ToLower)
		l.Lines[i] = prefix + operand + comment
	}
}

// isDataLabel returns true if the label name suggests it's a data definition, not a routine.
func isDataLabel(name string) bool {
	if strings.HasPrefix(name, "msg_") || strings.HasPrefix(name, "tkn_") {
		return true
	}
	if strings.HasSuffix(name, "_setup") || strings.HasSuffix(name, "_setup_regs") {
		return true
	}
	if strings.HasSuffix(name, "_effects") || strings.HasSuffix(name, "_effects_regs") {
		return true
	}
	if strings.HasSuffix(name, "_end") || strings.HasSuffix(name, "_start") ||
		strings.HasSuffix(name, "_data") || strings.HasSuffix(name, "_table") ||
		strings.HasSuffix(name, "_text") || strings.HasSuffix(name, "_colours") ||
		strings.HasSuffix(name, "_codes") || strings.HasSuffix(name, "_handlers") {
		return true
	}
	return false
}

// isDataDirective returns true if the line starts with a data assembler directive
// or a data-emitting macro.
func isDataDirective(line string) bool {
	t := strings.TrimSpace(strings.ToLower(line))
	return strings.HasPrefix(t, ".byte") || strings.HasPrefix(t, ".quad") ||
		strings.HasPrefix(t, ".space") || strings.HasPrefix(t, ".asciz") ||
		strings.HasPrefix(t, ".set") || strings.HasPrefix(t, ".align 0") ||
		strings.HasPrefix(t, ".word") || strings.HasPrefix(t, ".hword") ||
		strings.HasPrefix(t, "defb") || strings.HasPrefix(t, "defw") ||
		strings.HasPrefix(t, "defm") || strings.HasPrefix(t, "defs") ||
		strings.HasPrefix(t, "equ") ||
		strings.HasPrefix(t, "_hwordbe") || strings.HasPrefix(t, "ventry")
}

// isConditionalDirective returns true if the line is a conditional assembly directive
// (.if, .else, .elseif, .endif) that should be treated as transparent when scanning
// for the content following a label.
func isConditionalDirective(line string) bool {
	t := strings.TrimSpace(strings.ToLower(line))
	return strings.HasPrefix(t, ".if ") || strings.HasPrefix(t, ".if\t") ||
		t == ".else" || strings.HasPrefix(t, ".else ") || strings.HasPrefix(t, ".else\t") ||
		strings.HasPrefix(t, ".elseif ") || strings.HasPrefix(t, ".elseif\t") ||
		t == ".endif" || strings.HasPrefix(t, ".endif ") || strings.HasPrefix(t, ".endif\t")
}

// isDashLine returns true if the line (after comment char and space) consists entirely of dashes.
func isDashLine(line, cc string) bool {
	prefix := cc + " "
	if !strings.HasPrefix(line, prefix) {
		return false
	}
	rest := strings.TrimPrefix(line, prefix)
	if len(rest) == 0 {
		return false
	}
	return strings.Count(rest, "-") == len(rest)
}

// trimBlankCommentLines removes leading and trailing blank comment lines
// (lines that are just the comment char, possibly with trailing spaces) from a slice.
func trimBlankCommentLines(lines []string, cc string) []string {
	isBlank := func(s string) bool {
		return strings.TrimSpace(s) == cc || strings.TrimSpace(s) == ""
	}
	start := 0
	for start < len(lines) && isBlank(lines[start]) {
		start++
	}
	end := len(lines)
	for end > start && isBlank(lines[end-1]) {
		end--
	}
	return lines[start:end]
}

// FixRoutineHeaders auto-injects or fixes routine header comment blocks.
// Parses any existing comment block above a routine label into description,
// On entry, and On exit sections, then rebuilds the header with dashes and
// any missing sections filled with TODOs.
func (l *Linter) FixRoutineHeaders() {
	c := l.commentChar()
	dashes := c + " " + strings.Repeat("-", 78)

	i := 0
	for i < len(l.Lines) {
		trimmed := strings.TrimSpace(l.Lines[i])

		// Only consider snake_case global labels (routine entry points)
		if !globalLabelValid.MatchString(trimmed) {
			i++
			continue
		}

		labelName := trimmed
		if idx := strings.Index(labelName, ":"); idx >= 0 {
			labelName = labelName[:idx]
		}
		if isDataLabel(labelName) {
			i++
			continue
		}
		// Look past blank lines, comments, labels, and conditional directives after the label for a data directive.
		{
			k := i + 1
			for k < len(l.Lines) {
				s := strings.TrimSpace(l.Lines[k])
				if s == "" || strings.HasPrefix(s, c+" ") || s == c ||
					globalLabelValid.MatchString(s) || isConditionalDirective(s) {
					k++
					continue
				}
				break
			}
			if k < len(l.Lines) && isDataDirective(l.Lines[k]) {
				i++
				continue
			}
		}

		// Scan backwards: skip blank lines, then collect comment lines
		j := i - 1
		blanksBefore := 0
		for j >= 0 && strings.TrimSpace(l.Lines[j]) == "" {
			blanksBefore++
			j--
		}

		// Collect comment lines (in forward order)
		headerEnd := j
		headerStart := j + 1
		hasDashes := false
		for j >= 0 {
			lt := strings.TrimSpace(l.Lines[j])
			if lt == "" || !strings.HasPrefix(lt, c) {
				break
			}
			headerStart = j
			if isDashLine(lt, c) {
				hasDashes = true
			}
			j--
		}

		// Comments separated by a blank line without dashes aren't a header
		// (e.g. copyright block above a blank line)
		hasComment := headerStart <= headerEnd
		if blanksBefore > 0 && !hasDashes {
			hasComment = false
		}

		// Parse existing comment into description / on-entry / on-exit
		var descLines, sectionLines, entryLines, exitLines []string
		multipleSections := false
		if hasComment {
			// Count On entry/On exit occurrences to detect multi-section headers
			entryCount := 0
			exitCount := 0
			for k := headerStart; k <= headerEnd; k++ {
				lt := strings.TrimSpace(l.Lines[k])
				if strings.Contains(lt, "On entry:") {
					entryCount++
				}
				if strings.Contains(lt, "On exit:") || strings.Contains(lt, "On return:") {
					exitCount++
				}
			}
			multipleSections = entryCount > 1 || exitCount > 1

			if multipleSections {
				// Multiple On entry/On exit sections — preserve verbatim
				inSections := false
				for k := headerStart; k <= headerEnd; k++ {
					lt := strings.TrimSpace(l.Lines[k])
					if isDashLine(lt, c) {
						continue
					}
					if !inSections && (strings.Contains(lt, "On entry:") || strings.Contains(lt, "On exit:") || strings.Contains(lt, "On return:")) {
						inSections = true
					}
					if inSections {
						sectionLines = append(sectionLines, l.Lines[k])
					} else {
						descLines = append(descLines, lt)
					}
				}
			} else {
				// Single or no On entry/On exit — parse into sections
				section := "desc"
				for k := headerStart; k <= headerEnd; k++ {
					lt := strings.TrimSpace(l.Lines[k])
					if isDashLine(lt, c) {
						continue
					}
					if strings.Contains(lt, "On entry:") {
						section = "entry"
						continue
					}
					if strings.Contains(lt, "On exit:") || strings.Contains(lt, "On return:") {
						section = "exit"
						continue
					}
					switch section {
					case "desc":
						descLines = append(descLines, lt)
					case "entry":
						entryLines = append(entryLines, lt)
					case "exit":
						exitLines = append(exitLines, lt)
					}
				}
			}
		}

		// Trim blank comment lines from section boundaries
		descLines = trimBlankCommentLines(descLines, c)
		entryLines = trimBlankCommentLines(entryLines, c)
		exitLines = trimBlankCommentLines(exitLines, c)
		sectionLines = trimBlankCommentLines(sectionLines, c)

		// Fill missing sections with TODOs
		if len(descLines) == 0 {
			descLines = []string{c + " TODO: Description"}
		}

		// Build the new header
		var header []string
		header = append(header, dashes)
		header = append(header, descLines...)
		header = append(header, dashes)
		if multipleSections {
			header = append(header, sectionLines...)
		} else if l.FileInfo.Type == FileTypeAarch64Asm {
			if len(entryLines) == 0 {
				entryLines = []string{c + "   TODO"}
			}
			if len(exitLines) == 0 {
				exitLines = []string{c + "   TODO"}
			}
			header = append(header, c+" On entry:")
			header = append(header, entryLines...)
			header = append(header, c+" On exit:")
			header = append(header, exitLines...)
		}

		// Replace old comment lines (if any) with the new header
		removeFrom := i // default: insert before label, remove nothing
		if hasComment {
			removeFrom = headerStart
		}
		newLines := make([]string, 0, len(l.Lines)+len(header))
		newLines = append(newLines, l.Lines[:removeFrom]...)
		newLines = append(newLines, header...)
		newLines = append(newLines, l.Lines[i:]...)
		l.Lines = newLines
		i = removeFrom + len(header) + 1 // advance past header and label
	}
}

// FixZ80RomIndentation normalises leading whitespace to exactly 2 spaces
// for content lines in Z80 ROM files (rom0.s, rom1.s). Comment-only lines
// whose comment character starts within the first 10 chars are also pulled
// back to col 2 (rom convention: content sits at col 2). Comment-only lines
// at col 10+ are left for FormatWhitespace to push to col 50 or wrap.
// Other Z80 files (e.g. tests) intentionally use nested indentation and
// are left untouched.
func (l *Linter) FixZ80RomIndentation() {
	if l.FileInfo.Type != FileTypeZ80Asm {
		return
	}
	if !strings.Contains(l.Filename, "/roms/rom") {
		return
	}
	cc := l.commentChar()
	for i, line := range l.Lines {
		if line == "" {
			continue
		}
		if line[0] != ' ' && line[0] != '\t' {
			continue
		}
		trimmed := strings.TrimLeft(line, " \t")
		if trimmed == "" {
			continue
		}
		if strings.HasPrefix(trimmed, cc) {
			leading := len(line) - len(trimmed)
			if leading >= 10 {
				continue
			}
		}
		l.Lines[i] = "  " + trimmed
	}
}

// FormatWhitespace applies instruction alignment and comment alignment.
// Tab expansion and trailing-whitespace stripping are done earlier by
// NormaliseLineWhitespace.
func (l *Linter) FormatWhitespace() {
	r1 := regexp.MustCompile("[[:space:]]*;")
	r2 := regexp.MustCompile("[[:space:]]*//")
	r3 := regexp.MustCompile("// L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]$")
	for i, line := range l.Lines {
		stage := "initial-spaces"
		initialSpaces := ""
		instruction := ""
		lineRest := ""
		matches := true
		for _, j := range line {
			switch stage {
			case "initial-spaces":
				if j == ' ' {
					initialSpaces = initialSpaces + " "
					continue
				}
				stage = "instruction"
				instruction = string(j)
			case "instruction":
				if j == ' ' {
					stage = "post-instruction-spaces"
					continue
				}
				instruction = instruction + string(j)
			case "post-instruction-spaces":
				if j != ' ' {
					stage = "linerest"
					lineRest = string(j)
				}
			case "linerest":
				lineRest = lineRest + string(j)
			}
		}
		if stage != "linerest" || len(instruction) > 7 || strings.Contains(instruction, ":") || (instruction[0] != '_' && !unicode.IsLetter(rune(instruction[0])) && !unicode.IsNumber(rune(instruction[0]))) {
			matches = false
		}
		if matches {
			line = initialSpaces + instruction + strings.Repeat(" ", 8-len(instruction)) + lineRest
		}
		start := line
		if len(start) > 10 {
			start = start[:10]
		}
		if strings.Contains(start, ";") || strings.Contains(start, "#") || strings.Contains(start, "//") || (!strings.Contains(line, ";") && !strings.Contains(line, "//")) {
			l.Lines[i] = line
			continue
		}
		loc1 := r1.FindStringIndex(line)
		loc2 := r2.FindStringIndex(line)
		var loc []int
		commentIdentifier := ";"
		indent := 50
		if len(loc2) == 0 || (len(loc1) != 0 && loc1[0] < loc2[0]) {
			loc = loc1
		} else {
			commentIdentifier = "//"
			loc = loc2
		}
		line = line[:loc[0]] + "  " + commentIdentifier + line[loc[1]:]
		first := strings.Index(line, commentIdentifier)
		if r3.MatchString(line) {
			indent -= 9
		}
		if first < indent {
			numberOfExtraSpaces := indent - first
			line = line[:first] + strings.Repeat(" ", numberOfExtraSpaces) + line[first:]
		}
		if first > indent {
			line = strings.TrimRight(line[:first], " ") + "\n" + strings.Repeat(" ", indent) + line[first:]
		}
		l.Lines[i] = line
	}
}

// NormaliseLineWhitespace expands tabs to 4 spaces and strips trailing
// whitespace on every line. Runs first so later rules see consistent input
// (column counts reflect visual columns, no stray trailing spaces). Scoped
// to assembly files — Go, shell, and other languages have their own
// formatters (gofmt, shfmt) that treat tabs as significant.
func (l *Linter) NormaliseLineWhitespace() {
	if l.FileInfo.Type != FileTypeZ80Asm && l.FileInfo.Type != FileTypeAarch64Asm {
		return
	}
	for i, line := range l.Lines {
		l.Lines[i] = strings.TrimRight(strings.ReplaceAll(line, "\t", "    "), " ")
	}
}

// RunAll applies all rules in order, dispatching based on file type.
func (l *Linter) RunAll() {
	// Canonicalise whitespace before any other rule sees the input.
	l.NormaliseLineWhitespace()

	// Normalise # line comments to target comment style before copyright check
	if l.FileInfo.Type == FileTypeZ80Asm || l.FileInfo.Type == FileTypeAarch64Asm {
		l.FixHashComments()
	}

	// All text files get copyright check
	l.FixCopyright()

	// Assembly-only rules
	if l.FileInfo.Type == FileTypeAarch64Asm || l.FileInfo.Type == FileTypeZ80Asm {
		l.SplitLabelLines()
		l.FixDotLLabels()
		l.CheckLabels()
		l.FixInstructionCase()
		l.FixCommaSpacing()
		l.FixHexCase()
		if l.FileInfo.Type == FileTypeZ80Asm {
			l.FixBinaryPrefix()
			l.FixDirectiveNames()
			l.FixRegisterCase()
		}
		if l.FileInfo.Type == FileTypeAarch64Asm {
			l.FixRoutineHeaders()
		}
		l.FixRoutineSpacing()
		l.FixZ80RomIndentation()
		l.FormatWhitespace()
	}
}
