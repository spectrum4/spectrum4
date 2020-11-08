package libgentest

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/ghodss/yaml"
)

type (
	Generator struct {
		inputDir        string
		outputFile      string
		writer          io.Writer
		sortedTestFiles []string
		unitTests       []UnitTest
	}
	UnitTests struct {
		Tests []UnitTest `json:"tests"`
	}
	UnitTest struct {
		Name    string        `json:"name"`
		Setup   SystemContext `json:"setup"`
		Effects SystemContext `json:"effects"`
		// internal fields
		Routine string `json:"-"` // routine that the unit test tests
	}
	SystemContext struct {
		RAM       NamedValue `json:"ram"`
		SysVars   NamedValue `json:"sysvars"`
		Registers NamedValue `json:"registers"`
	}
	NamedValue  map[string]StoredValue
	StoredValue struct {
		Quad    *uint64 `json:"quad,omitempty"`
		Pointer *string `json:"pointer,omitempty"`
	}
)

func (value StoredValue) Write(w io.Writer, ramSetupEntries NamedValue, includeType bool) error {
	switch {
	case value.Quad != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 8                                 // 8 => quad")
		}
		fmt.Fprintf(w, "  .quad 0x%016x                // quad: 0x%016x\n", *value.Quad, *value.Quad)
	case value.Pointer != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 16                                // 16 => pointer")
		}
		index := ramSetupEntries.IndexOf(*value.Pointer)
		if index < 0 {
			return fmt.Errorf("Pointer to undefined ram entry %v", *value.Pointer)
		}
		fmt.Fprintf(w, "  .quad %-16v                  // %v\n", index, *value.Pointer)
	default:
		return fmt.Errorf("No Quad or Pointer specified in %v", value)
	}
	return nil
}

func (registerEntries NamedValue) WriteRegisters(w io.Writer, ramSetupEntries NamedValue) error {
	var updatedRegisters uint64
	for k, v := range registerEntries {
		e := fmt.Errorf("Unknown register %v (name must be 'x<0-31>')", k)
		if k[0] != 'x' {
			return e
		}
		registerIndex, err := strconv.Atoi(k[1:])
		if err != nil {
			return e
		}
		if registerIndex < 0 || registerIndex > 30 {
			return e
		}
		updatedRegisters |= 1 << (registerIndex * 2)
		if v.Pointer != nil {
			updatedRegisters |= 1 << (registerIndex*2 + 1)
		}
	}

	fmt.Fprintf(w, "  .quad 0b%064b\n", updatedRegisters)

	sortedRegisters := registerEntries.SortedNames()
	for _, register := range sortedRegisters {
		value := registerEntries[register]
		err := value.Write(w, ramSetupEntries, false)
		if err != nil {
			return err
		}
	}
	return nil
}

func (nv NamedValue) SortedNames() []string {
	s := make([]string, len(nv), len(nv))
	i := 0
	for k := range nv {
		s[i] = k
		i++
	}
	sort.Strings(s)
	return s
}

func (nv NamedValue) IndexOf(entry string) int {
	sorted := nv.SortedNames()
	for i := range sorted {
		if entry == sorted[i] {
			return i
		}
	}
	return -1
}

func New(inputDir string, outputFile string) *Generator {
	return &Generator{
		inputDir:        inputDir,
		outputFile:      outputFile,
		sortedTestFiles: []string{},
		unitTests:       []UnitTest{},
	}
}

func (generator *Generator) FindFiles() error {
	err := filepath.Walk(generator.inputDir,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if strings.HasSuffix(path, ".yml") {
				fmt.Printf("Adding test(s) from %v...\n", path)
				generator.sortedTestFiles = append(generator.sortedTestFiles, path)
			}
			return nil
		})
	if err != nil {
		return err
	}
	return nil
}

func (generator *Generator) LoadFiles() error {
	for _, yamlPath := range generator.sortedTestFiles {
		absYAMLPath, err := filepath.Abs(yamlPath)
		if err != nil {
			return fmt.Errorf("Could not determine absolute file location of unit test file %q: %s", yamlPath, err)
		}
		data, err := ioutil.ReadFile(absYAMLPath)
		if err != nil {
			return fmt.Errorf("Could not read unit test file %q: %s", absYAMLPath, err)
		}
		// JSON is valid YAML, so we can safely convert, even if it is already JSON
		rawJSON, err := yaml.YAMLToJSON(data)
		if err != nil {
			return fmt.Errorf("Could not interpret unit test file %q as YAML: %s", absYAMLPath, err)
		}
		uts := new(UnitTests)
		dec := json.NewDecoder(bytes.NewBuffer(rawJSON))
		dec.DisallowUnknownFields()
		err = dec.Decode(uts)
		if err != nil {
			if ute, isUnmarshallTypeError := err.(*json.UnmarshalTypeError); isUnmarshallTypeError {
				log.Printf("Value: %v / Type: %v / Offset: %v / Struct: %v / Field: %v", ute.Value, ute.Type, ute.Offset, ute.Struct, ute.Field)
			}
			return fmt.Errorf("Unit test file %q has invalid properties: %s", absYAMLPath, err)
		}
		for i := range uts.Tests {
			uts.Tests[i].Routine = filepath.Base(yamlPath[:len(yamlPath)-4])
		}
		generator.unitTests = append(generator.unitTests, (uts.Tests)...)
	}
	return nil
}

func (generator *Generator) GenerateFile() error {
	file, err := os.Create(generator.outputFile)
	if err != nil {
		return err
	}
	fmt.Printf("Generating %v...\n", generator.outputFile)
	generator.writer = file
	generator.Header()
	for _, unitTest := range generator.unitTests {
		testCode, err := unitTest.Test()
		if err != nil {
			return err
		}
		_, err = generator.writer.Write(testCode)
		if err != nil {
			return err
		}
	}
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
	for _, unitTest := range generator.unitTests {
		fmt.Fprintln(w, `  .quad `+unitTest.SymbolName()+``)
	}
}

func (unitTest *UnitTest) SymbolName() string {
	return "test_" + strings.Replace(unitTest.Name, " ", "_", -1)
}

func (unitTest *UnitTest) Test() ([]byte, error) {
	symbolName := unitTest.SymbolName()
	w := new(bytes.Buffer)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintf(w, "############# Test %v %v\n", unitTest.Name, strings.Repeat("#", 54-len(unitTest.Name)))
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# Test case definition")
	fmt.Fprintf(w, "%v:\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_name\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_ram\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_sysvars\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_registers\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_ram\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_sysvars\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_registers\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_exec\n", symbolName)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case name")
	fmt.Fprintf(w, "%v_name:\n", symbolName)
	fmt.Fprintf(w, "  .asciz %q\n", unitTest.Name)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case setup")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# RAM setup")
	fmt.Fprintf(w, "%v_setup_ram:\n", symbolName)

	ramEntryCount := len(unitTest.Setup.RAM)

	fmt.Fprintf(w, "  .quad %-4v                              // Number of RAM entries = %v\n", ramEntryCount, ramEntryCount)

	ramSetupEntries := unitTest.Setup.RAM
	sortedRAMEntries := ramSetupEntries.SortedNames()

	for _, ramEntry := range sortedRAMEntries {
		fmt.Fprintf(w, "  .quad %v_setup_ram_%v\n", symbolName, ramEntry)
	}

	for _, ramEntry := range sortedRAMEntries {
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, ".align 3")
		fmt.Fprintf(w, "%v_setup_ram_%v:\n", symbolName, ramEntry)
		e := ramSetupEntries[ramEntry]
		err := e.Write(w, ramSetupEntries, true)
		if err != nil {
			return nil, err
		}
		fmt.Fprintf(w, "  .asciz %q %v // name: %q\n", ramEntry, strings.Repeat(" ", 29-len(ramEntry)), ramEntry)
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# System variables setup")
	fmt.Fprintf(w, "%v_setup_sysvars:\n", symbolName)
	// TODO
	fmt.Fprintln(w, "  .quad 0b0000000000000000000000100000000000000000000000000000000000000000")
	fmt.Fprintln(w, "                                          // Index 41 => CURCHL")
	fmt.Fprintln(w, "  .quad 0b0000000000000000000000100000000000000000000000000000000000000000")
	fmt.Fprintln(w, "                                          // Index 41: 1 => CURCHL value is pointer")
	fmt.Fprintln(w, "  .quad 0                                 // [CURCHL] = channel_block")
	fmt.Fprintln(w, "")

	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# Registers setup")
	fmt.Fprintf(w, "%v_setup_registers:\n", symbolName)
	err := unitTest.Setup.Registers.WriteRegisters(w, ramSetupEntries)
	if err != nil {
		return nil, err
	}
	fmt.Fprintln(w, "")

	fmt.Fprintln(w, "# Test case effects")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# RAM effects")
	fmt.Fprintf(w, "%v_effects_ram:\n", symbolName)
	// TODO
	fmt.Fprintln(w, "  .quad 1                                 // Number of RAM entries = 1")
	fmt.Fprintln(w, "  .quad 0                                 // channel_block updated")
	fmt.Fprintln(w, "  .quad 16                                // 16 => new value is pointer")
	fmt.Fprintln(w, "  .quad 1                                 // value = new_input_routine")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# System variable effects")
	fmt.Fprintf(w, "%v_effects_sysvars:\n", symbolName)
	// TODO
	fmt.Fprintln(w, "  .quad 0b0000000000000000000000000000000000000000000000000000000000000000")
	fmt.Fprintln(w, "  .quad 0b0000000000000000000000000000000000000000000000000000000000000000")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# Register effects")
	fmt.Fprintf(w, "%v_effects_registers:\n", symbolName)
	// TODO
	err = unitTest.Effects.Registers.WriteRegisters(w, ramSetupEntries)
	if err != nil {
		return nil, err
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case execution")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 2")
	fmt.Fprintf(w, "%v_exec:\n", symbolName)
	fmt.Fprintln(w, "  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.")
	fmt.Fprintln(w, "  mov     x29, sp                         // Update frame pointer to new stack location.")
	fmt.Fprintln(w, "  ldp     x0, x1, [x0]                    // Restore x0, x1 values")
	fmt.Fprintf(w, "  bl      %v\n", unitTest.Routine)
	fmt.Fprintln(w, "  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.")
	fmt.Fprintln(w, "  ret")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	return w.Bytes(), nil
}
