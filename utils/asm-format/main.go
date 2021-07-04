package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

func main() {
	transform(os.Stdin)
}

func transform(file *os.File) {
	scanner := bufio.NewScanner(file)
	r1 := regexp.MustCompile("[[:space:]]*;")
	r2 := regexp.MustCompile("[[:space:]]*//")
	r3 := regexp.MustCompile("// L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]$")
	for scanner.Scan() {
		line := scanner.Text()
		// if ';' or '//' in first 10 characters, or not in string at all, don't touch line
		line = strings.TrimRight(strings.ReplaceAll(line, "\t", "    "), " ")
		start := line
		if len(start) > 10 {
			start = start[:10]
		}
		if strings.Contains(start, ";") || strings.Contains(start, "#") || strings.Contains(start, "//") || (!strings.Contains(line, ";") && !strings.Contains(line, "//")) {
			fmt.Println(line)
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
			line = line[:first] + "\n" + strings.Repeat(" ", indent) + line[first:]
		}
		fmt.Println(line)
	}
}
