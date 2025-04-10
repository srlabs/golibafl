# Harnesses

## Targets
This directory contains all the targets used to test and evaluate our fuzzer.
The targets include:
- A custom path constraint target
- [prometheus](https://github.com/prometheus/prometheus)
- [caddy](https://github.com/caddyserver/caddy)
- [burntsushi-toml](https://github.com/BurntSushi/toml)

The fuzzed functionality for all non-custom targets was copied from the [oss-fuzz](https://github.com/google/oss-fuzz) repository.