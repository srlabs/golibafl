package main

import (
	"fmt"
	"os"
	"runtime/debug"
	"syscall"
	"unsafe"
)

// #include <stdint.h>
import "C"

//export LLVMFuzzerTestOneInput
func LLVMFuzzerTestOneInput(data *C.char, size C.size_t) C.int {
	defer catchPanics()
	// Call your harness function here
	return 0
}

func catchPanics() {
	if recover() != nil {
		syscall.Kill(os.Getpid(), syscall.SIGABRT)
	}
}

// Call this function from the main function of your Rust-based fuzzer to ensure everything works correctly.
//
//export LLVMFuzzerInitialize
func LLVMFuzzerInitialize(argc *C.int, argv ***C.char) C.int {
	// disable garbage collector. Garbage collection will only be triggered when the runtime reaches its software memory left (define below)
	debug.SetGCPercent(-1)
	// Set soft memory limit for each process of the runtime to max of 1GiB RAM.
	debug.SetMemoryLimit(1024 * 1024 * 1024)
	return 0
}

// Runner code
func main() {
	if len(os.Args) == 2 {
		path := os.Args[1]
		info, err := os.Stat(path)
		if err != nil {
			fmt.Println("Failed to access path", err)
		}

		if info.IsDir() {
			files, _ := os.ReadDir(path)
			for _, file := range files {
				filePath := path + string(os.PathSeparator) + file.Name()
				content, _ := os.ReadFile(filePath)
				cSize := C.size_t(len(content))
				if cSize > 1 {
					cData := (*C.char)(unsafe.Pointer(&content[0]))
					LLVMFuzzerTestOneInput(cData, cSize)
				}
			}
		} else {
			content, _ := os.ReadFile(path)
			cSize := C.size_t(len(content))
			if cSize > 1 {
				cData := (*C.char)(unsafe.Pointer(&content[0]))
				LLVMFuzzerTestOneInput(cData, cSize)
			}
		}
	} else {
		fmt.Println("Usage: <folderPath>")
	}
}
