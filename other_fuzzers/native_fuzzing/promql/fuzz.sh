#!/bin/bash
#

# delete old corpus
rm -rf ./testdata/fuzz/FuzzMe

while true; do
    go test -fuzz FuzzMe -test.fuzzcachedir=./testdata/fuzz -parallel=1
    sleep 1
done

