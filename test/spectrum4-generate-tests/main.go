package main

import (
	"log"
	"os"

	"github.com/spectrum4/spectrum4/test/libgentest"
)

func main() {
	log.SetFlags(0)
	log.SetPrefix("spectrum4-generate-tests: ")
	if len(os.Args) < 3 {
		log.Printf("Invalid arguments specified: %q", os.Args[1:])
		log.Fatal(Usage())
	}
	generator := libgentest.New(os.Args[1], os.Args[2])
	err := generator.FindFiles()
	if err != nil {
		log.Fatal(err)
	}
	err = generator.LoadFiles()
	if err != nil {
		log.Fatal(err)
	}
	err = generator.GenerateFile()
	if err != nil {
		log.Fatal(err)
	}
}

func Usage() string {
	return "Usage: spectrum4-generate-tests <INPUT DIRECTORY> <OUTPUT FILE>"
}
