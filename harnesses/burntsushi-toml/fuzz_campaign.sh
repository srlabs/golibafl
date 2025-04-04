#!/bin/bash

trap 'kill 0' SIGINT

for i in {1..24}; do
    timeout 1h ./golibafl fuzz -j 4-7 -o ./output -p 1339
    ./get_cov.sh >> cov
done

