#!/bin/bash
#
mkdir -p corpus
mkdir -p crashes
rm -f corpus/*
rm -f crashes/*
echo "1234" > ./corpus/init
./fuzz_binary ./corpus -fork=1 -ignore_crashes=1 -ignore_timeouts=1 -close_fd_mask=3 -artifact_prefix=./crashes/ -ignore_ooms=1 -entropic=1 -keep_seed=1 -cross_over_uniform_dist=1 -entropic_scale_per_exec_time=1 -detect_leaks=0

#./fuzz_binary
