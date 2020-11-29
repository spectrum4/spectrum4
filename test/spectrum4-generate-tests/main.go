package main

import (
	"log"
	"os"

	"github.com/spectrum4/spectrum4/test/gentest"
	"github.com/spectrum4/spectrum4/test/sysvars"
)

func main() {
	log.SetFlags(0)
	log.SetPrefix("spectrum4-generate-tests: ")
	if len(os.Args) < 4 {
		log.Printf("Invalid arguments specified: %q", os.Args[1:])
		log.Fatal(Usage())
	}
	generator := gentest.New(os.Args[1], os.Args[3])
	sysVars, err := sysvars.Fetch(os.Args[2])
	if err != nil {
		log.Fatal(err)
	}
	err = generator.FindFiles()
	if err != nil {
		log.Fatal(err)
	}
	err = generator.LoadFiles()
	if err != nil {
		log.Fatal(err)
	}
	err = generator.GenerateFile(sysVars)
	if err != nil {
		log.Fatal(err)
	}
}

func Usage() string {
	return "Usage: spectrum4-generate-tests <INPUT DIRECTORY> <BSS FILE> <OUTPUT FILE>"
}
