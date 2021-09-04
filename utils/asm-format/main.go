package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
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
		// remove leading space before first ';' or '//'
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
