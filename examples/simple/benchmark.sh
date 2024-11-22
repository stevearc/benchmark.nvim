#!/bin/bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

nvim --clean -u "harness.lua" -c "lua benchmark()"
