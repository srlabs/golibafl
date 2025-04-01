#!/bin/sh

if [ ! -d ./output ]; then
    echo "Error: The './output' directory is missing. Please ensure the fuzzer's output directory exists in your current location."
    exit 1
fi 

# get caddy specific coverage
go test -tags=gocov -run=FuzzMe -cover -coverpkg=$(go list -deps -test| grep "github.com/caddy" |  tr '\n' ',') -coverprofile cover.out
go tool cover -html cover.out  -o cover.html
