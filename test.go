package main

import "fmt"

func main() {
	// +  mov     x3, #0xe38f
	// +  movk    x3, #0x8e38, lsl #16
	// +  movk    x3, #0x38e3, lsl #32
	// +  movk    x3, #0xe38e, lsl #48            // x3 = 16397105843297379215
	// +  umulh   x4, x3, x1                      // x4 = x1 * 16397105843297379215 / 18446744073709551616 = x1 / 1.125
	// +  lsr     x4, x4, #4                      // x4 = x4 / 16 = x1 / 18
	x3 := uint64(0xe38f)
	for x1 := uint64(0); x1 < 216; x1++ {
		x4 := uint64(x3 * x1 / 16 / 65536)
		fmt.Printf("%v: %v / %v\n", x1, x4, x1/18)
	}
}
