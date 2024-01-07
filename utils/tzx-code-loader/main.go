// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021 Spectrum +4 Authors. All rights reserved.

package main

import (
	"io/ioutil"
	"log"
	"os"
	"strconv"

	"github.com/spectrum4/spectrum4/utils/tzx"
	"github.com/spectrum4/spectrum4/utils/zxbasic"
	"github.com/spectrum4/spectrum4/utils/zxtape"
)

func main() {
	log.SetFlags(0)
	log.SetPrefix("tzx-code-loader: ")
	if len(os.Args) != 9 {
		log.Fatalf("Usage: %v INPUT_CODE_FILE OUTPUT_TZX_FILE LOAD_ADDRESS CHANNEL_ADDRESS DEFAULT_CHANNEL BASIC_NAME CODE_NAME GAPS_IN_MILLISECONDS", os.Args[0])
	}
	inputFile := os.Args[1]
	outputFile := os.Args[2]
	address, err := strconv.Atoi(os.Args[3])
	if err != nil {
		log.Fatalf("Error converting load address %q to number: %v", os.Args[3], err)
	}
	chAddress, err := strconv.Atoi(os.Args[4])
	if err != nil {
		log.Fatalf("Error converting channel address %q to number: %v", os.Args[4], err)
	}
	defaultCh, err := strconv.Atoi(os.Args[5])
	if err != nil {
		log.Fatalf("Error converting default channel %q to number: %v", os.Args[5], err)
	}
	basicName := os.Args[6]
	codeName := os.Args[7]
	gapsInMilliseconds, err := strconv.Atoi(os.Args[8])
	if err != nil {
		log.Fatalf("Error converting gaps in milliseconds %q to number: %v", os.Args[8], err)
	}
	gapsMillis := uint16(gapsInMilliseconds)
	loadAddress := uint16(address)
	channelAddress := uint16(chAddress)
	defaultChannel := uint16(defaultCh)
	loader := BASICLoader(loadAddress, channelAddress, defaultChannel, basicName)
	inputData, err := ioutil.ReadFile(inputFile)
	if err != nil {
		log.Fatalf("Error opening code file for reading: %v", err)
	}
	code := zxtape.Code(inputData, loadAddress, codeName)
	tzxData := tzx.New(1, 13, gapsMillis, loader, code)
	err = ioutil.WriteFile(outputFile, tzxData.Bytes(), 0644)
	if err != nil {
		log.Fatalf("Error writing tzx file: %v", err)
	}
}

func BASICLoader(loadAddress uint16, channelAddress uint16, defaultChannel uint16, name string) *zxtape.File {
	p := &zxbasic.Program{
		Lines: []zxbasic.Line{
			{
				Number: 10,
				Tokens: []zxbasic.Token{
					zxbasic.CLEAR,
					zxbasic.Number(loadAddress - 1),
				},
			},
			{
				Number: 20,
				Tokens: []zxbasic.Token{
					zxbasic.POKE,
					zxbasic.Number(23610),
					zxbasic.String(","),
					zxbasic.Number(255),
				},
			},
			{
				Number: 30,
				Tokens: []zxbasic.Token{
					zxbasic.LOAD,
					zxbasic.String(`""`),
					zxbasic.CODE,
				},
			},
			{
				Number: 40,
				Tokens: []zxbasic.Token{
					zxbasic.REM,
					zxbasic.String("The next POKE controls where test output is written to. Set to 2 for upper screen or 3 for printer. Type GOTO 50 to rerun tests."),
				},
			},
			{
				Number: 50,
				Tokens: []zxbasic.Token{
					zxbasic.POKE,
					zxbasic.Number(channelAddress),
					zxbasic.String(","),
					zxbasic.Number(defaultChannel),
				},
			},
			{
				Number: 60,
				Tokens: []zxbasic.Token{
					zxbasic.RANDOMIZE,
					zxbasic.USR,
					zxbasic.Number(loadAddress),
				},
			},
		},
	}
	return zxtape.Program(p, name, 10)
}
