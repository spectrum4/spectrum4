// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021 Spectrum +4 Authors. All rights reserved.

package zxbasic

import (
	"log"
	"strconv"
)

type (
	KeyWord byte
	Program struct {
		Lines []Line
		Vars  Vars
	}
	Line struct {
		Number uint16
		Tokens []Token
	}
	Vars struct {
	}
	Token interface {
		Bytes() []byte
	}
	ZXNum struct {
		Display string
		Value   [5]byte
	}
	ZXString []byte
)

const (
	RND KeyWord = iota + 165
	INKEY_STRING
	PI
	FN
	POINT
	SCREEN_STRING
	ATTR
	AT
	TAB
	VAL_STRING
	CODE
	VAL
	LEN
	SIN
	COS
	TAN
	ASN
	ACS
	ATN
	LN
	EXP
	INT
	SQR
	SGN
	ABS
	PEEK
	IN
	USR
	STR_STRING
	CHR_STRING
	NOT
	BIN
	OR
	AND
	LESS_THAN_OR_EQUAL
	GREATER_THAN_OR_EQUAL
	NOT_EQUAL_TO
	LINE
	THEN
	TO
	STEP
	DEF_FN
	CAT
	FORMAT
	MOVE
	ERASE
	OPEN_HASH
	CLOSE_HASH
	MERGE
	VERIFY
	BEEP
	CIRCLE
	INK
	PAPER
	FLASH
	BRIGHT
	INVERSE
	OVER
	OUT
	LPRINT
	LLIST
	STOP
	READ
	DATA
	RESTORE
	NEW
	BORDER
	CONTINUE
	DIM
	REM
	FOR
	GO_TO
	GO_SUB
	INPUT
	LOAD
	LIST
	LET
	PAUSE
	NEXT
	POKE
	PRINT
	PLOT
	RUN
	SAVE
	RANDOMIZE
	IF
	CLS
	DRAW
	CLEAR
	RETURN
	COPY
)

func (k KeyWord) Bytes() []byte {
	return []byte{
		byte(k),
	}
}

func (n *ZXNum) Bytes() []byte {
	result := []byte(n.Display)
	result = append(result, 0x0e, n.Value[0], n.Value[1], n.Value[2], n.Value[3], n.Value[4])
	return result
}

func Number(value uint16) *ZXNum {
	return &ZXNum{
		Value: [5]byte{
			0x0,
			0x0,
			byte(value & 0xff),
			byte(value >> 8),
			0x0,
		},
		Display: strconv.Itoa(int(value)),
	}
}

func String(s string) *ZXString {
	zs := ZXString(s)
	return &zs
}

func (s *ZXString) Bytes() []byte {
	return []byte(*s)
}

func (p *Program) Code() []byte {
	result := []byte{}
	for _, line := range p.Lines {
		result = append(result, line.Bytes()...)
	}
	return result
}

func (p *Program) Bytes() []byte {
	result := p.Code()
	result = append(result, p.Vars.Bytes()...)
	return result
}

func (l *Line) Bytes() []byte {
	data := []byte{}
	for _, t := range l.Tokens {
		data = append(data, t.Bytes()...)
	}
	data = append(data, byte(0x0d))
	if len(data) > (1<<16)-1 {
		log.Fatalf("Line length > %v: %v", (1<<16)-1, len(data))
	}
	result := []byte{
		byte(l.Number >> 8),
		byte(l.Number & 0xff),
		byte(len(data) & 0xff),
		byte(len(data) >> 8),
	}
	result = append(result, data...)
	return result
}

func (v *Vars) Bytes() []byte {
	result := []byte{}
	return result
}

func (p *Program) VarOffset() uint16 {
	return uint16(len(p.Code()))
}
