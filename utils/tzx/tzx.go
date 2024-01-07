// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021 Spectrum +4 Authors. All rights reserved.

package tzx

import (
	"log"

	"github.com/spectrum4/spectrum4/utils/zxtape"
)

type (
	File struct {
		Header Header
		Blocks []Block
	}
	Header struct {
		MajorVersion uint8
		MinorVersion uint8
	}
	Block interface {
		Bytes() []byte
	}
	V10Block struct {
		Data     []byte
		EndDelay uint16
	}
)

func (f *File) Bytes() []byte {
	result := f.Header.Bytes()
	for _, b := range f.Blocks {
		result = append(result, b.Bytes()...)
	}
	return result
}

func (v10 *V10Block) Bytes() []byte {
	if len(v10.Data) > (1<<16)-1 {
		log.Fatalf("Bytes block longer than %v: %v", (1<<16)-1, len(v10.Data))
	}
	b := []byte{
		0x10,
		byte(v10.EndDelay & 0xff),
		byte(v10.EndDelay >> 8),
		byte(len(v10.Data) & 0xff),
		byte(len(v10.Data) >> 8),
	}
	return append(b, v10.Data...)
}

func (h *Header) Bytes() []byte {
	res := []byte("ZXTape!...")
	res[7] = 0x1a
	res[8] = h.MajorVersion
	res[9] = h.MinorVersion
	return res
}

func New(majorVersion uint8, minorVersion uint8, gapsInMilliseconds uint16, files ...*zxtape.File) *File {
	blocks := []Block{}
	for _, f := range files {
		blocks = append(blocks,
			&V10Block{
				Data:     f.Header.Bytes(),
				EndDelay: gapsInMilliseconds,
			},
			&V10Block{
				Data:     f.Data.Bytes(),
				EndDelay: gapsInMilliseconds,
			},
		)
	}
	if len(blocks) > 0 {
		blocks[len(blocks)-1].(*V10Block).EndDelay = 0
	}
	return &File{
		Header: Header{
			MajorVersion: majorVersion,
			MinorVersion: minorVersion,
		},
		Blocks: blocks,
	}
}
