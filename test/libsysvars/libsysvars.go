package libsysvars

import (
	"bufio"
	"os"
	"strings"
)

func Fetch(bssFile string) ([]string, error) {
	sysVars := []string{}
	f, err := os.Open(bssFile)
	if err != nil {
		return nil, err
	}
	scanner := bufio.NewScanner(f)
	inSysvars := false
	for scanner.Scan() {
		line := scanner.Text()
		tokens := strings.Fields(line)
		if len(tokens) > 0 && strings.HasSuffix(tokens[0], ":") {
			if !inSysvars {
				if tokens[0] == "sysvars:" {
					inSysvars = true
				}
			} else if tokens[0] == "sysvars_end:" {
				break
			} else {
				sysVars = append(sysVars, tokens[0][:len(tokens[0])-1])
			}
		}
	}
	return sysVars, nil
}
