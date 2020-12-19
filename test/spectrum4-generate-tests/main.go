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
	if len(os.Args) != 5 {
		log.Printf("Invalid arguments specified: %q", os.Args[1:])
		log.Fatal(Usage())
	}
	generator := gentest.New(os.Args[1])
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
	err = generator.GenerateAarch64(sysVars, os.Args[3])
	if err != nil {
		log.Fatal(err)
	}
	err = generator.GenerateZ80(sysVars, os.Args[4])
	if err != nil {
		log.Fatal(err)
	}
}

func Usage() string {
	return "Usage: spectrum4-generate-tests <INPUT DIRECTORY> <BSS FILE> <AARCH64 OUTPUT FILE> <Z80 OUTPUT FILE>"
}
