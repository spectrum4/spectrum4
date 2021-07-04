package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

func main() {
	oldTimeString := os.Getenv("OLD_TIME")
	newTime := time.Now().UnixNano()
	oldTime := newTime

	if oldTimeString != "" {
		oldTime, _ = strconv.ParseInt(oldTimeString, 16, 64)
	}
	duration := time.Duration(newTime - oldTime)
	fmt.Printf("echo '%s' && ", duration)
	fmt.Printf("export OLD_TIME='%x'\n", newTime)
}
