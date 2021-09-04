package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	check := false
	if len(os.Args) > 1 {
		check = os.Args[1] == "check"
	}
	exitCode := transform(os.Stdin, check)
	if exitCode == 1 {
		log.Print("Script needs formatting")
	}
	os.Exit(exitCode)
}

func transform(file *os.File, check bool) (exitCode int) {
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		oldline := scanner.Text()
		// if ';' or '//' in first 10 characters, or not in string at all, don't touch line
		line := strings.TrimRight(strings.ReplaceAll(oldline, "\t", "    "), " ")
		if !check {
			fmt.Println(line)
		} else if line != oldline {
			return 1
		}
	}
	return 0
}
