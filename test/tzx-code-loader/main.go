package main

import (
	"io/ioutil"
	"log"
	"os"
	"strconv"

	"github.com/spectrum4/spectrum4/test/tzx"
	"github.com/spectrum4/spectrum4/test/zxbasic"
	"github.com/spectrum4/spectrum4/test/zxtape"
)

func main() {
	log.SetFlags(0)
	log.SetPrefix("tzx-code-loader: ")
	if len(os.Args) != 8 {
		log.Fatalf("Usage: %v INPUT_CODE_FILE OUTPUT_TZX_FILE LOAD_ADDRESS CHANNEL_ADDRESS BASIC_NAME CODE_NAME GAPS_IN_MILLISECONDS", os.Args[0])
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
	basicName := os.Args[5]
	codeName := os.Args[6]
	gapsInMilliseconds, err := strconv.Atoi(os.Args[7])
	if err != nil {
		log.Fatalf("Error converting gaps in milliseconds %q to number: %v", os.Args[7], err)
	}
	gapsMillis := uint16(gapsInMilliseconds)
	loadAddress := uint16(address)
	channelAddress := uint16(chAddress)
	loader := BASICLoader(loadAddress, channelAddress, basicName)
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

func BASICLoader(loadAddress uint16, channelAddress uint16, name string) *zxtape.File {
	p := &zxbasic.Program{
		Lines: []zxbasic.Line{
			{
				Number: 10,
				Tokens: []zxbasic.Token{
					zxbasic.REM,
					zxbasic.String("The next POKE controls where test output is written to. Set to 2 for upper screen or 3 for printer. Type RUN to rerun tests."),
				},
			},
			{
				Number: 20,
				Tokens: []zxbasic.Token{
					zxbasic.POKE,
					zxbasic.Number(channelAddress),
					zxbasic.String(","),
					zxbasic.Number(2),
				},
			},
			{
				Number: 30,
				Tokens: []zxbasic.Token{
					zxbasic.RANDOMIZE,
					zxbasic.USR,
					zxbasic.Number(loadAddress),
				},
			},
			{
				Number: 40,
				Tokens: []zxbasic.Token{
					zxbasic.STOP,
				},
			},
			{
				Number: 50,
				Tokens: []zxbasic.Token{
					zxbasic.CLEAR,
					zxbasic.Number(loadAddress - 1),
				},
			},
			{
				Number: 60,
				Tokens: []zxbasic.Token{
					zxbasic.POKE,
					zxbasic.Number(23610),
					zxbasic.String(","),
					zxbasic.Number(255),
				},
			},
			{
				Number: 70,
				Tokens: []zxbasic.Token{
					zxbasic.LOAD,
					zxbasic.String(`""`),
					zxbasic.CODE,
				},
			},
			{
				Number: 80,
				Tokens: []zxbasic.Token{
					zxbasic.GO_TO,
					zxbasic.Number(30),
				},
			},
		},
	}
	return zxtape.Program(p, name, 50)
}
