#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' worlds.json)
common_args=(--worldAddress="$worldAddress")

run_tests() {
  forge_opts="-vvv $*"
  echo "Running command: pnpm mud test ${common_args[*]} --forgeOptions='$forge_opts'"
  pnpm mud test "${common_args[@]}" --forgeOptions="$forge_opts"
}

run_gas_reporter() {
  forge_opts="-vvv $*"
  echo "Running command: GAS_REPORTER_ENABLED=true pnpm mud test ${common_args[*]} --forgeOptions='$forge_opts' | pnpm gas-report --save gas-report.json --stdin"
  GAS_REPORTER_ENABLED=true pnpm mud test "${common_args[@]}" --forgeOptions="$forge_opts" | pnpm gas-report --save gas-report.json --stdin
}

# Parse args, separate --with-gas
with_gas=false
args=()
for arg in "$@"; do
  if [[ "$arg" == "--with-gas" ]]; then
    with_gas=true
  else
    args+=("$arg")
  fi
done

if $with_gas; then
  run_gas_reporter "${args[@]}"
else
  run_tests "${args[@]}"
fi

