// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021 Spectrum +4 Authors. All rights reserved.

package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
	"unicode"
)

func main() {
	check := false
	if len(os.Args) > 1 {
		check = os.Args[1] == "check"
	}
	exitCode := transform(os.Stdin, check)
	if exitCode == 1 {
		log.Print("Source code needs formatting")
	}
	os.Exit(exitCode)
}

func transform(file *os.File, check bool) (exitCode int) {
	scanner := bufio.NewScanner(file)
	r1 := regexp.MustCompile("[[:space:]]*;")
	r2 := regexp.MustCompile("[[:space:]]*//")
	r3 := regexp.MustCompile("// L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]$")
	for scanner.Scan() {
		oldline := scanner.Text()
		// if ';' or '//' in first 10 characters, or not in string at all, don't touch line
		line := strings.TrimRight(strings.ReplaceAll(oldline, "\t", "    "), " ")
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
		// remove leading space before first ';' or '//'
		start := line
		if len(start) > 10 {
			start = start[:10]
		}
		if strings.Contains(start, ";") || strings.Contains(start, "#") || strings.Contains(start, "//") || (!strings.Contains(line, ";") && !strings.Contains(line, "//")) {
			if !check {
				fmt.Println(line)
			} else if line != oldline {
				return 1
			}
			continue
		}
		loc1 := r1.FindStringIndex(line)
		loc2 := r2.FindStringIndex(line)
		var loc []int
		commentIdentifier := ";"
		indent := 42
		if len(loc2) == 0 || (len(loc1) != 0 && loc1[0] < loc2[0]) {
			loc = loc1
		} else {
			commentIdentifier = "//"
			indent = 50
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
		if !check {
			fmt.Println(line)
		} else if line != oldline {
			return 1
		}
	}
	return 0
}
