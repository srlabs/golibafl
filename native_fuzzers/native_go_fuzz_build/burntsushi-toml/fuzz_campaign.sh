#!/bin/bash

trap 'kill 0' SIGINT

for i in {1..24}; do
    timeout 1h ./fuzz.sh
    ./get_cov.sh >> cov
done

