## Harness template
This directory provides a minimal Go harness for use with our LibAFL fuzzer.
Simply implement your harness function and invoke it inside `LLVMFuzzerTestOneInput`.