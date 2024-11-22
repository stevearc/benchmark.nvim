#!/bin/bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
cmd=
plugin=

benchmark() {
  echo "Benchmarking ${plugin}..."
  echo "Num files: ${DIR_SIZE-10000} (from DIR_SIZE environment variable)"
  echo "Iterations: ${ITERATIONS-10} (from ITERATIONS environment variable)"
  echo "Warm-up cycles: ${WARM_UP-1} (from WARM_UP environment variable)"
  echo ""
  nvim --clean -u "${plugin}.lua" -c "lua benchmark(${ITERATIONS-10})"
  cat tmp/benchmark.txt
}

jit_profile() {
  nvim --clean -u "${plugin}.lua" -c "lua jit_profile()"
}

flame_profile() {
  nvim --clean -u "${plugin}.lua" -c "lua flame_profile()"
  echo "Saved to tmp/profile.json"
  echo "Visit https://ui.perfetto.dev/ and load the profile.json file"
}

cmd="${1?Usage: $0 <benchmark|jit_profile|flame_profile> <plugin>}"
shift
plugin="${1?Usage: $0 <benchmark|jit_profile|flame_profile> <plugin>}"
shift
if [ "$cmd" = "benchmark" ]; then
  benchmark "$@"
elif [ "$cmd" = "jit_profile" ]; then
  jit_profile "$@"
elif [ "$cmd" = "flame_profile" ]; then
  flame_profile "$@"
else
  echo "Usage: $0 <benchmark|jit_profile|flame_profile> <plugin>"
  exit 1
fi
