package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		log.Fatal("cleanup: Filename not passed in")
	}
	file := os.Args[1]
	out, err := exec.Command("/usr/bin/git", "checkout", "-f", file).CombinedOutput()
	fmt.Println(string(out))
	if err != nil {
		log.Fatalf("Error running 'git checkout %q': %s", file, err)
	}
	lines, err := readLines(file)
	if err != nil {
		log.Fatalf("Error reading file %v: %s", file, err)
	}
	re := regexp.MustCompile(`^ {0,5};; *[^ ;][^ ;]*`)
	re2 := regexp.MustCompile(`^ {0,5};; *`)
	newlines := []string{}
	for _, line := range lines {
		matched := false
		fixed := ""
		newline := string(re.ReplaceAllFunc([]byte(line), func(match []byte) []byte {
			matched = true
			fixed = strings.ReplaceAll(strings.ToLower(string(match)), "-", "_") + ":"
			fixed = strings.ReplaceAll(fixed, `+`, "_plus_")
			fixed = strings.ReplaceAll(fixed, `&`, "and")
			fixed = strings.ReplaceAll(fixed, `@`, "at")
			fixed = strings.ReplaceAll(fixed, `/`, "slash")
			fixed = strings.ReplaceAll(fixed, `?`, "question")
			fixed = strings.ReplaceAll(fixed, `$`, "string")
			fixed = strings.ReplaceAll(fixed, `,`, "comma")
			fixed = strings.ReplaceAll(fixed, `(`, "")
			fixed = strings.ReplaceAll(fixed, `)`, "")
			fixed = strings.ReplaceAll(fixed, `*`, "times")
			fixed = strings.ReplaceAll(fixed, `^`, "to_the")
			fixed = re2.ReplaceAllString(fixed, "")
			if len(match)-len(fixed) > 0 {
				fixed += strings.Repeat(" ", len(match)-len(fixed))
			}
			return []byte(fixed)
		}))
		newline = strings.TrimRight(newline, " ")

		if matched && !strings.HasSuffix(newline, ":") && !strings.Contains(newline, ";") {

			newlines = append(newlines,
				string(re.ReplaceAllFunc([]byte(line), func(match []byte) []byte {
					return []byte(";" + strings.Repeat(" ", len(match)-1))
				})),
				strings.TrimRight(fixed, " "),
			)
		} else {
			newlines = append(newlines, newline)
		}
	}
	if err := writeLines(newlines, file); err != nil {
		log.Fatalf("Error updating file %v: %s", file, err)
	}
}

// readLines reads a whole file into memory
// and returns a slice of its lines.
func readLines(path string) ([]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines, scanner.Err()
}

// writeLines writes the lines to the given file.
func writeLines(lines []string, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	w := bufio.NewWriter(file)
	for _, line := range lines {
		fmt.Fprintln(w, line)
	}
	return w.Flush()
}
