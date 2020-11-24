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
		ASM     *string       `json:"asm"`
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
		ASM     *string      `json:"asm,omitempty"`
		Quad    *interface{} `json:"quad,omitempty"`
		Pointer *string      `json:"pointer,omitempty"`
	}
)

func (value StoredValue) Write(w io.Writer, symbolName string, ramSetupEntries NamedValue, includeType bool) error {
	switch {
	case value.ASM != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 8                                 // 8 => quad")
		}
		fmt.Fprintf(w, "  .quad %v_%v\n", symbolName, *value.ASM)
	case value.Pointer != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 16                                // 16 => pointer")
		}
		index := ramSetupEntries.IndexOf(*value.Pointer)
		if index < 0 {
			return fmt.Errorf("Pointer to undefined ram entry %v", *value.Pointer)
		}
		fmt.Fprintf(w, "  .quad %-33v // %v\n", index, *value.Pointer)
	case value.Quad != nil:
		if includeType {
			fmt.Fprintln(w, "  .quad 8                                 // 8 => quad")
		}
		fmt.Fprintf(w, "  .quad %v\n", *value.Quad)
	default:
		return fmt.Errorf("No Quad nor Pointer nor ASM specified in %v", value)
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
		dec.UseNumber()
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

func (generator *Generator) GenerateFile(sysVars []string) error {
	file, err := os.Create(generator.outputFile)
	if err != nil {
		return err
	}
	fmt.Printf("Generating %v...\n", generator.outputFile)
	generator.writer = file
	generator.Header()
	for _, unitTest := range generator.unitTests {
		testCode, err := unitTest.Test(sysVars)
		if err != nil {
			return err
		}
		_, err = file.Write(testCode)
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
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintln(w, "all_tests:")
	fmt.Fprintf(w, "  .quad 0x%016x                // Number of tests.\n", len(generator.unitTests))
	for _, unitTest := range generator.unitTests {
		fmt.Fprintf(w, "  .quad %v\n", unitTest.SymbolName())
	}
}

func (unitTest *UnitTest) TestName() string {
	return unitTest.Routine + " " + unitTest.Name
}

func (unitTest *UnitTest) SymbolName() string {
	return "test_" + strings.Replace(unitTest.TestName(), " ", "_", -1)
}

func (unitTest *UnitTest) Test(sysVars []string) ([]byte, error) {
	symbolName := unitTest.SymbolName()
	w := new(bytes.Buffer)
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	fmt.Fprintf(w, "############# Test %v %v\n", unitTest.TestName(), strings.Repeat("#", 54-len(unitTest.TestName())))
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
	fmt.Fprintf(w, "  .asciz %q\n", unitTest.TestName())
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
		err := e.Write(w, symbolName, ramSetupEntries, true)
		if err != nil {
			return nil, err
		}
		fmt.Fprintf(w, "  .asciz %q %v // name: %q\n", ramEntry, strings.Repeat(" ", 29-len(ramEntry)), ramEntry)
	}

	err := unitTest.Setup.SysVars.Write(w, "System variables setup", symbolName, "setup_sysvars", "sysvar", sysVars, ramSetupEntries)
	if err != nil {
		return nil, err
	}

	registers := make([]string, 30, 30)
	for i := range registers {
		registers[i] = fmt.Sprintf("x%v", i)
	}
	err = unitTest.Setup.Registers.Write(w, "Registers setup", symbolName, "setup_registers", "register", registers, ramSetupEntries)
	if err != nil {
		return nil, err
	}

	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "# Test case effects")

	err = unitTest.Effects.RAM.Write(w, "RAM effects", symbolName, "effects_ram", "RAM entry", sortedRAMEntries, ramSetupEntries)
	if err != nil {
		return nil, err
	}

	err = unitTest.Effects.SysVars.Write(w, "System variable effects", symbolName, "effects_sysvars", "sysvar", sysVars, ramSetupEntries)
	if err != nil {
		return nil, err
	}

	err = unitTest.Effects.Registers.Write(w, "Registers effects", symbolName, "effects_registers", "register", registers, ramSetupEntries)
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
	if unitTest.ASM != nil {
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, "# Test case custom ASM")
		fmt.Fprintln(w, "")
		fmt.Fprintln(w, re.ReplaceAllString(*unitTest.ASM, "${1}"+symbolName+"_${2}:"))
	}
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, "##########################################################################")
	return w.Bytes(), nil
}

func (nv NamedValue) Write(w io.Writer, title string, symbolName string, subsection string, indexDescription string, entryNames []string, ramSetupEntries NamedValue) error {
	fmt.Fprintln(w, "")
	fmt.Fprintln(w, ".align 3")
	fmt.Fprintf(w, "# %v\n", title)
	fmt.Fprintf(w, "%v_%v:\n", symbolName, subsection)
	maskQuadCount := (len(entryNames) + 31) / 32
	found := 0
	entries := []string{}
	for i := 0; i < maskQuadCount; i++ {
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
					entries = append(entries, fmt.Sprintf("  .quad 0x%016x                // %v = %v", ramSetupEntries.IndexOf(*sv.Pointer), key, *sv.Pointer))
				case sv.Quad != nil:
					comments = append(comments, fmt.Sprintf("                                          // Bits %v-%v = 0b01 => %v (%v index %v) is absolute value", 2*j, 2*j+1, entry, indexDescription, j+i*32))
					entries = append(entries, fmt.Sprintf("  .quad %-33v // %v", *sv.Quad, key))
				default:
					return fmt.Errorf("No Quad nor Pointer nor ASM specified in %v", sv)
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
