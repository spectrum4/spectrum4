package gentest

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/ghodss/yaml"
)

var (
	re *regexp.Regexp = regexp.MustCompile("(?m)^( *)([a-zA-Z][a-zA-Z0-9_]*):")
)

type (
	Generator struct {
		inputDir        string
		sortedTestFiles []string
		unitTests       []UnitTests
	}
	UnitTests struct {
		Spectrum128K struct {
			Routine string
			Address uint16
		} `json:"spectrum128k"`
		Spectrum4 struct {
			Routine string
		} `json:"spectrum4"`
		Tests []UnitTest `json:"tests"`
	}
	UnitTest struct {
		Name         string        `json:"name"`
		Spectrum128K *Spectrum128K `json:"spectrum128k"`
		Spectrum4    *Spectrum4    `json:"spectrum4"`
	}
	Spectrum4 struct {
		Setup   SystemContext `json:"setup"`
		Effects SystemContext `json:"effects"`
		ASM     *string       `json:"asm"`
	}
	Spectrum128K struct {
		Setup   SystemContext `json:"setup"`
		Effects SystemContext `json:"effects"`
		ASM     *string       `json:"asm"`
	}
	SystemContext struct {
		Stack     NamedValue `json:"stack"`
		SysVars   NamedValue `json:"sysvars"`
		Registers NamedValue `json:"registers"`
	}
	NamedValue  map[string]StoredValue
	StoredValue struct {
		ASM     *string      `json:"asm,omitempty"`
		Value   *interface{} `json:"value,omitempty"`
		Pointer *string      `json:"pointer,omitempty"`
	}
)

func (value StoredValue) Write(w io.Writer, symbolName string, stackSetupEntries NamedValue, includeType bool) error {
	switch {
	case value.ASM != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 8                                 // 8 => value")
		}
		fmt.Fprintf(w, "  .quad %v_%v\n", symbolName, *value.ASM)
	case value.Pointer != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 16                                // 16 => pointer")
		}
		index := stackSetupEntries.IndexOf(*value.Pointer)
		if index < 0 {
			return fmt.Errorf("Pointer to undefined stack entry %v", *value.Pointer)
		}
		fmt.Fprintf(w, "  .quad %-33v // %v\n", index, *value.Pointer)
	case value.Value != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 8                                 // 8 => value")
		}
		fmt.Fprintf(w, "  .quad %v\n", *value.Value)
	default:
		return fmt.Errorf("No Value nor Pointer nor ASM specified in %v", value)
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

func New(inputDir string) *Generator {
	return &Generator{
		inputDir:        inputDir,
		sortedTestFiles: []string{},
		unitTests:       []UnitTests{},
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
	generator.unitTests = []UnitTests{}
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
		dec.UseNumber()
		err = dec.Decode(uts)
		if err != nil {
			if ute, isUnmarshallTypeError := err.(*json.UnmarshalTypeError); isUnmarshallTypeError {
				log.Printf("Value: %v / Type: %v / Offset: %v / Struct: %v / Field: %v", ute.Value, ute.Type, ute.Offset, ute.Struct, ute.Field)
			}
			return fmt.Errorf("Unit test file %q has invalid properties: %s", absYAMLPath, err)
		}
		generator.unitTests = append(generator.unitTests, *uts)
	}
	return nil
}

func (generator *Generator) GenerateZ80(sysVars []string, outputFile string) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	fmt.Printf("Generating %v...\n", outputFile)
	generator.Z80Header(file)
	for _, unitTests := range generator.unitTests {
		for i, unitTest := range unitTests.Tests {
			if unitTest.Spectrum128K != nil {
				testCode, err := unitTests.TestZ80(i)
				if err != nil {
					return err
				}
				_, err = file.Write(testCode)
				if err != nil {
					return err
				}
			}
		}
	}
	err = file.Close()
	if err != nil {
		return err
	}
	return nil
}

func (generator *Generator) GenerateAarch64(sysVars []string, outputFile string) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	fmt.Printf("Generating %v...\n", outputFile)
	generator.Aarch64Header(file)
	for _, unitTests := range generator.unitTests {
		for i, unitTest := range unitTests.Tests {
			if unitTest.Spectrum4 != nil {
				testCode, err := unitTests.TestAarch64(i, sysVars)
				if err != nil {
					return err
				}
				_, err = file.Write(testCode)
				if err != nil {
					return err
				}
			}
		}
	}
	err = file.Close()
	if err != nil {
		return err
	}
	return nil
}

func (generator *Generator) CommonHeader(w io.Writer) {
	fmt.Fprintln(w, "# This file is part of the Spectrum +4 Project.")
	fmt.Fprintln(w, "# Licencing information can be found in the LICENCE file")
	fmt.Fprintln(w, "# (C) 2019 Spectrum +4 Authors. All rights reserved.")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Generated from the files in the /test directory.")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# This file is auto-generated by all.sh. DO NOT EDIT!")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".text")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "")
}

func (generator *Generator) Z80Header(w io.Writer) {
	generator.CommonHeader(w)
	fmt.Fprintln(w, "all_tests:")
	testCount := 0
	for _, unitTests := range generator.unitTests {
		for _, unitTest := range unitTests.Tests {
			if unitTest.Spectrum128K != nil {
				testCount++
			}
		}
	}
	fmt.Fprintf(w, "  .byte 0x%02x                              ; Number of tests.\n", testCount)
	for _, unitTests := range generator.unitTests {
		for j, unitTest := range unitTests.Tests {
			if unitTest.Spectrum128K != nil {
				fmt.Fprintf(w, "  .hword %v\n", unitTests.SymbolNameZ80(j))
			}
		}
	}
}

func (generator *Generator) Aarch64Header(w io.Writer) {
	generator.CommonHeader(w)
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "all_tests:")
	testCount := 0
	for _, unitTests := range generator.unitTests {
		for _, unitTest := range unitTests.Tests {
			if unitTest.Spectrum4 != nil {
				testCount++
			}
		}
	}
	fmt.Fprintf(w, "  .quad 0x%016x                // Number of tests.\n", testCount)
	for _, unitTests := range generator.unitTests {
		for j, unitTest := range unitTests.Tests {
			if unitTest.Spectrum4 != nil {
				fmt.Fprintf(w, "  .quad %v\n", unitTests.SymbolName(j))
			}
		}
	}
}

func (unitTests *UnitTests) TestNameZ80(index int) string {
	return unitTests.Spectrum128K.Routine + " " + unitTests.Tests[index].Name
}

func (unitTests *UnitTests) TestName(index int) string {
	return unitTests.Spectrum4.Routine + " " + unitTests.Tests[index].Name
}

func (tests *UnitTests) SymbolNameZ80(index int) string {
	return "test_" + strings.Replace(strings.Replace(tests.TestNameZ80(index), " ", "_", -1), "-", "_", -1)
}

func (tests *UnitTests) SymbolName(index int) string {
	return "test_" + strings.Replace(tests.TestName(index), " ", "_", -1)
}

func (tests *UnitTests) TestZ80(index int) ([]byte, error) {
	unitTest := tests.Tests[index]
	symbolName := tests.SymbolNameZ80(index)
	w := new(bytes.Buffer)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintf(w, "############# Test %v %v\n", tests.TestNameZ80(index), strings.Repeat("#", 54-len(tests.TestNameZ80(index))))
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case definition")
	fmt.Fprintf(w, "%v:\n", symbolName)
	fmt.Fprintf(w, "  .hword %v_name\n", symbolName)
	fmt.Fprintf(w, "  .hword %v_setup_registers\n", symbolName)
	fmt.Fprintf(w, "  .hword %v_effects_registers\n", symbolName)
	fmt.Fprintf(w, "  .hword %v_exec\n", symbolName)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case name")
	fmt.Fprintf(w, "%v_name:\n", symbolName)
	fmt.Fprintf(w, "  .asciz %q\n", tests.TestNameZ80(index))
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case setup")
	fmt.Fprintln(w, "")

	registers := []string{
		"IX_lsb",
		"IX_msb",
		"IY_lsb",
		"IY_msb",
		"F'",
		"A'",
		"C'",
		"B'",
		"E'",
		"D'",
		"L'",
		"H'",
		"F",
		"A",
		"C",
		"B",
		"E",
		"D",
		"L",
		"H",
	}

	err := unitTest.Spectrum128K.Setup.Registers.WriteZ80(w, "Registers setup", symbolName, "setup_registers", "register", registers)
	if err != nil {
		return nil, err
	}

	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case effects")

	err = unitTest.Spectrum128K.Effects.Registers.WriteZ80(w, "Registers effects", symbolName, "effects_registers", "register", registers)
	if err != nil {
		return nil, err
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case execution")
	fmt.Fprintln(w, "")
	fmt.Fprintf(w, "%v_exec:\n", symbolName)
	fmt.Fprintln(w, "  pop     hl")
	fmt.Fprintf(w, "  call    0x%04x                          ; %v\n", tests.Spectrum128K.Address, tests.Spectrum128K.Routine)
	fmt.Fprintln(w, "  jp      test_exec_return")
	if unitTest.Spectrum128K.ASM != nil {
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, "# Test case custom ASM")
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, re.ReplaceAllString(*unitTest.Spectrum128K.ASM, "${1}"+symbolName+"_${2}:"))
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	return w.Bytes(), nil
}

func (tests *UnitTests) TestAarch64(index int, sysVars []string) ([]byte, error) {
	unitTest := tests.Tests[index]
	symbolName := tests.SymbolName(index)
	w := new(bytes.Buffer)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintf(w, "############# Test %v %v\n", tests.TestName(index), strings.Repeat("#", 54-len(tests.TestName(index))))
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# Test case definition")
	fmt.Fprintf(w, "%v:\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_name\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_stack\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_sysvars\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_setup_registers\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_stack\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_sysvars\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_effects_registers\n", symbolName)
	fmt.Fprintf(w, "  .quad %v_exec\n", symbolName)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case name")
	fmt.Fprintf(w, "%v_name:\n", symbolName)
	fmt.Fprintf(w, "  .asciz %q\n", tests.TestName(index))
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case setup")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "# Stack setup")
	fmt.Fprintf(w, "%v_setup_stack:\n", symbolName)

	stackEntryCount := len(unitTest.Spectrum4.Setup.Stack)

	fmt.Fprintf(w, "  .quad %-4v                              // Number of stack entries = %v\n", stackEntryCount, stackEntryCount)

	stackSetupEntries := unitTest.Spectrum4.Setup.Stack
	sortedStackEntries := stackSetupEntries.SortedNames()

	for _, stackEntry := range sortedStackEntries {
		fmt.Fprintf(w, "  .quad %v_setup_stack_%v\n", symbolName, stackEntry)
	}

	for _, stackEntry := range sortedStackEntries {
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, ".align 3")
		fmt.Fprintf(w, "%v_setup_stack_%v:\n", symbolName, stackEntry)
		e := stackSetupEntries[stackEntry]
		err := e.Write(w, symbolName, stackSetupEntries, true)
		if err != nil {
			return nil, err
		}
		fmt.Fprintf(w, "  .asciz %q %v // name: %q\n", stackEntry, strings.Repeat(" ", 29-len(stackEntry)), stackEntry)
	}

	err := unitTest.Spectrum4.Setup.SysVars.Write(w, "System variables setup", symbolName, "setup_sysvars", "sysvar", sysVars, stackSetupEntries)
	if err != nil {
		return nil, err
	}

	registers := make([]string, 30, 30)
	for i := range registers {
		registers[i] = fmt.Sprintf("x%v", i)
	}
	err = unitTest.Spectrum4.Setup.Registers.Write(w, "Registers setup", symbolName, "setup_registers", "register", registers, stackSetupEntries)
	if err != nil {
		return nil, err
	}

	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case effects")

	err = unitTest.Spectrum4.Effects.Stack.Write(w, "Stack effects", symbolName, "effects_stack", "stack entry", sortedStackEntries, stackSetupEntries)
	if err != nil {
		return nil, err
	}

	err = unitTest.Spectrum4.Effects.SysVars.Write(w, "System variable effects", symbolName, "effects_sysvars", "sysvar", sysVars, stackSetupEntries)
	if err != nil {
		return nil, err
	}

	err = unitTest.Spectrum4.Effects.Registers.Write(w, "Registers effects", symbolName, "effects_registers", "register", registers, stackSetupEntries)
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
	fmt.Fprintf(w, "  bl      %v\n", tests.Spectrum4.Routine)
	fmt.Fprintln(w, "  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.")
	fmt.Fprintln(w, "  ret")
	if unitTest.Spectrum4.ASM != nil {
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, "# Test case custom ASM")
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, re.ReplaceAllString(*unitTest.Spectrum4.ASM, "${1}"+symbolName+"_${2}:"))
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	return w.Bytes(), nil
}

func (nv NamedValue) WriteZ80(w io.Writer, title string, symbolName string, subsection string, indexDescription string, entryNames []string) error {

	fmt.Fprintln(w, "")
	fmt.Fprintf(w, "# %v\n", title)
	fmt.Fprintf(w, "%v_%v:\n", symbolName, subsection)
	maskValueCount := (len(entryNames) + 7) / 8
	found := 0
	entries := []string{}
	for i := 0; i < maskValueCount; i++ {
		var mask uint8 = 0
		comments := []string{}
		for j := 0; j < 8; j++ {
			if j+i*8 == len(entryNames) {
				break
			}
			entry := entryNames[j+i*8]
			key := "[" + entry + "]"
			if indexDescription == "register" {
				key = entry
			}
			if sv, exists := nv[entry]; exists {
				found++
				mask |= 1 << j
				switch {
				case sv.Value != nil:
					comments = append(comments, fmt.Sprintf("                                          ; Bit %v = 1 => %v (%v index %v) is absolute value", j, entry, indexDescription, j+i*8))
					switch t := (*sv.Value).(type) {
					case json.Number:
						v, err := t.Int64()
						if err != nil {
							return fmt.Errorf("In symbol %v: %v", symbolName, err)
						}
						entries = append(entries, fmt.Sprintf("  .byte %-33v ; %v = 0x%02x", t, key, v))
					default:
						entries = append(entries, fmt.Sprintf("  .byte %-33v ; %v", t, key))
					}
				default:
					return fmt.Errorf("No Value specified in %v", sv)
				}
			}
		}
		fmt.Fprintf(w, "  .byte 0b%08b\n", mask)
		for i := range comments {
			fmt.Fprintln(w, comments[i])
		}
	}
	if len(nv) > found {
		return fmt.Errorf("%v unknown entries for section %v_%v", len(nv)-found, symbolName, subsection)
	}
	for _, e := range entries {
		fmt.Fprintln(w, e)
	}
	return nil
}

func (nv NamedValue) Write(w io.Writer, title string, symbolName string, subsection string, indexDescription string, entryNames []string, stackSetupEntries NamedValue) error {
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintf(w, "# %v\n", title)
	fmt.Fprintf(w, "%v_%v:\n", symbolName, subsection)
	maskValueCount := (len(entryNames) + 31) / 32
	found := 0
	entries := []string{}
	for i := 0; i < maskValueCount; i++ {
		var mask uint64 = 0
		comments := []string{}
		for j := 0; j < 32; j++ {
			if j+i*32 == len(entryNames) {
				break
			}
			entry := entryNames[j+i*32]
			key := "[" + entry + "]"
			if indexDescription == "register" {
				key = entry
			}
			if sv, exists := nv[entry]; exists {
				found++
				mask |= 1 << (2 * j)
				switch {
				case sv.ASM != nil:
					comments = append(comments, fmt.Sprintf("                                          // Bits %v-%v = 0b01 => %v (%v index %v) is absolute value", 2*j, 2*j+1, entry, indexDescription, j+i*32))
					entries = append(entries, fmt.Sprintf("  .quad %-33v // %v", symbolName+"_"+*sv.ASM, key))
				case sv.Pointer != nil:
					mask |= 1 << (2*j + 1)
					comments = append(comments, fmt.Sprintf("                                          // Bits %v-%v = 0b11 => %v (%v index %v) is pointer", 2*j, 2*j+1, entry, indexDescription, j+i*32))
					entries = append(entries, fmt.Sprintf("  .quad 0x%016x                // %v = %v", stackSetupEntries.IndexOf(*sv.Pointer), key, *sv.Pointer))
				case sv.Value != nil:
					comments = append(comments, fmt.Sprintf("                                          // Bits %v-%v = 0b01 => %v (%v index %v) is absolute value", 2*j, 2*j+1, entry, indexDescription, j+i*32))
					entries = append(entries, fmt.Sprintf("  .quad %-33v // %v", *sv.Value, key))
				default:
					return fmt.Errorf("No Value nor Pointer nor ASM specified in %v", sv)
				}
			}
		}
		fmt.Fprintf(w, "  .quad 0b%064b\n", mask)
		for i := range comments {
			fmt.Fprintln(w, comments[i])
		}
	}
	if len(nv) > found {
		return fmt.Errorf("%v unknown entries for section %v_%v", len(nv)-found, symbolName, subsection)
	}
	for _, e := range entries {
		fmt.Fprintln(w, e)
	}
	return nil
}
