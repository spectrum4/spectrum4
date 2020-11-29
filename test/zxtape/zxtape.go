package zxtape

import (
	"log"

	"github.com/spectrum4/spectrum4/test/zxbasic"
)

const (
	Header Type = 0x00
	Data   Type = 0xff
)

type (
	Type  byte
	Block struct {
		Type Type
		Data []byte
	}
	File struct {
		Header *Block
		Data   *Block
	}
)

func (b *Block) Bytes() []byte {
	result := []byte{
		byte(b.Type),
	}
	result = append(result, b.Data...)
	result = append(result, xor(result))
	return result
}

func xor(b []byte) byte {
	result := byte(0)
	for _, b := range b {
		result ^= b
	}
	return result
}

func Code(code []byte, address uint16, name string) *File {
	return Encode(code, 3, name, address, 32768)
}

func Program(p *zxbasic.Program, name string, autostart uint16) *File {
	return Encode(p.Bytes(), 0, name, autostart, p.VarOffset())
}

func Encode(data []byte, dataType uint8, name string, param1 uint16, param2 uint16) *File {
	if len([]byte(name)) > 10 {
		log.Fatalf("File name too long: %v is more than 10 bytes", name)
	}
	header := []byte{
		dataType,
		32, 32, 32, 32, 32, 32, 32, 32, 32, 32, // filename initialise with spaces - replaced later on
		byte(len(data) & 0xff),
		byte(len(data) >> 8),
		byte(param1 & 0xff),
		byte(param1 >> 8),
		byte(param2 & 0xff),
		byte(param2 >> 8),
	}
	for i, j := range []byte(name) {
		header[i+1] = j
	}
	return &File{
		Header: &Block{
			Type: Header,
			Data: header,
		},
		Data: &Block{
			Type: Data,
			Data: data,
		},
	}
}
