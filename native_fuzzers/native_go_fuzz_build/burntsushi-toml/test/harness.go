package main

import (
	"bytes"
	"fmt"
	"github.com/BurntSushi/toml"
    "os"
)

func main() {
    data, err := os.ReadFile(os.Args[1])
	if len(data) >= 2048 {
		return
	}

    fmt.Println("Running: ", data)

	var v any
	_, err = toml.Decode(string(data), &v)
	if err != nil {
		return
	}

	buf := new(bytes.Buffer)
	err = toml.NewEncoder(buf).Encode(v)
	if err != nil {
		panic(fmt.Sprintf("failed to encode decoded document: %s", err))
	}

	var v2 any
	_, err = toml.Decode(buf.String(), &v2)
	if err != nil {
		panic(fmt.Sprintf("failed round trip: %s", err))
	}

	return
}
