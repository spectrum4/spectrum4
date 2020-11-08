package libgentest

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

type Generator struct {
	inputDir   string
	outputFile string
	writer     io.Writer
}

func New(inputDir string, outputFile string) *Generator {
	return &Generator{
		inputDir:   inputDir,
		outputFile: outputFile,
	}
}

func (generator *Generator) LoadFiles() error {
	err := filepath.Walk(generator.inputDir,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if strings.HasSuffix(path, ".yml") {
				fmt.Printf("Loading %v...", path)
			}
			return nil
		})
	if err != nil {
		return err
	}
	return nil
}

func (generator *Generator) GenerateFile() error {
	file, err := os.Create(generator.outputFile)
	if err != nil {
		return err
	}
	generator.writer = file
	generator.Header()
	generator.Test()
	err = file.Close()
	if err != nil {
		return err
	}
	return nil
}

func (generator *Generator) Header() {
	w := generator.writer
	fmt.Fprintln(w, `# This file is part of the Spectrum +4 Project.`)
	fmt.Fprintln(w, `# Licencing information can be found in the LICENCE file`)
	fmt.Fprintln(w, `# (C) 2019 Spectrum +4 Authors. All rights reserved.`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# Generated from the files in the /test directory.`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# This file is auto-generated by all.sh. DO NOT EDIT!`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.text`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `all_tests:`)
	fmt.Fprintln(w, `  .quad 1                                 // Number of tests.`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1`)
}

func (generator *Generator) Test() {
	w := generator.writer
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `##########################################################################`)
	fmt.Fprintln(w, `############# Test po_change test case 1 #################################`)
	fmt.Fprintln(w, `##########################################################################`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# Test case definition`)
	fmt.Fprintln(w, `test_po_change_test_case_1:`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_name`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_sysvars`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_registers`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_effects_ram`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_effects_sysvars`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_effects_registers`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_exec`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# Test case name`)
	fmt.Fprintln(w, `test_po_change_test_case_1_name:`)
	fmt.Fprintln(w, `  .asciz "po_change test case 1"`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# Test case setup`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# RAM setup`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_ram:`)
	fmt.Fprintln(w, `  .quad 3                                 // Number of RAM entries = 3`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram_old_input_routine`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram_new_input_routine`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram_channel_block`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_ram_old_input_routine:`)
	fmt.Fprintln(w, `  .quad 8                                 // 8 => quad`)
	fmt.Fprintln(w, `  .quad 0x0123456789abcdef                // quad: 0x0123456789abcdef`)
	fmt.Fprintln(w, `  .asciz "old_input_routine"              // name: "old_input_routine"`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_ram_new_input_routine:`)
	fmt.Fprintln(w, `  .quad 8                                 // 8 => quad`)
	fmt.Fprintln(w, `  .quad 0xfedcba9876543210                // quad: 0xfedcba9876543210`)
	fmt.Fprintln(w, `  .asciz "new_input_routine"              // name: "new_input_routine"`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_ram_channel_block:`)
	fmt.Fprintln(w, `  .quad 16                                // 16 => pointer`)
	fmt.Fprintln(w, `  .quad 0                                 // old_input_routine`)
	fmt.Fprintln(w, `  .asciz "channel_block"                  // name: "channel_block"`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# System variables setup`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_sysvars:`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000100000000000000000000000000000000000000000`)
	fmt.Fprintln(w, `                                          // Index 41 => CURCHL`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000100000000000000000000000000000000000000000`)
	fmt.Fprintln(w, `                                          // Index 41: 1 => CURCHL value is pointer`)
	fmt.Fprintln(w, `  .quad 2`)
	fmt.Fprintln(w, `                                          // [CURCHL] = channel_block`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# Registers setup`)
	fmt.Fprintln(w, `test_po_change_test_case_1_setup_registers:`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000000000000000000000000000000000001100000000`)
	fmt.Fprintln(w, `  .quad 1`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# Test case effects`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# RAM effects`)
	fmt.Fprintln(w, `test_po_change_test_case_1_effects_ram:`)
	fmt.Fprintln(w, `  .quad 1                                 // Number of RAM entries = 1`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram_channel_block`)
	fmt.Fprintln(w, `  .quad 16                                // 16 => pointer`)
	fmt.Fprintln(w, `  .quad test_po_change_test_case_1_setup_ram_new_input_routine`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# System variable effects`)
	fmt.Fprintln(w, `test_po_change_test_case_1_effects_sysvars:`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000000000000000000000000000000000000000000000`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000000000000000000000000000000000000000000000`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 3`)
	fmt.Fprintln(w, `# Register effects`)
	fmt.Fprintln(w, `test_po_change_test_case_1_effects_registers:`)
	fmt.Fprintln(w, `  .quad 0b0000000000000000000000000000000000000000000000000000110000000000`)
	fmt.Fprintln(w, `  .quad 2`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `# Test case execution`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `.align 2`)
	fmt.Fprintln(w, `test_po_change_test_case_1_exec:`)
	fmt.Fprintln(w, `  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.`)
	fmt.Fprintln(w, `  mov     x29, sp                         // Update frame pointer to new stack location.`)
	fmt.Fprintln(w, `  ldp     x0, x1, [x0]                    // Restore x0, x1 values`)
	fmt.Fprintln(w, `  bl      po_change`)
	fmt.Fprintln(w, `  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.`)
	fmt.Fprintln(w, `  ret`)
	fmt.Fprintln(w, ``)
	fmt.Fprintln(w, `##########################################################################`)
}
