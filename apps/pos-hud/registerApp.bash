#!/bin/bash

# Set chain ID from environment variable or default to local development
chainId=${CHAIN_ID:-31337}

# Set RPC URL based on chain ID
case "${chainId}" in
  "695569")
    rpcUrl="https://rpc.pyropechain.com"
    ;;
  "17069")
    rpcUrl="https://rpc.garnetchain.com"
    ;;
  "690")
    rpcUrl="https://rpc.redstonechain.com"
    ;;
  *)
    # Default to local development
    rpcUrl="http://127.0.0.1:8545"
    ;;
esac

echo "Using RPC: $rpcUrl"
echo "Using Chain Id: $chainId"

# Extract worldAddress using awk
worldAddress=$(awk -v id="$chainId" -F'"' '$2 == id {getline; print $4}' ../../packages/world/worlds.json)

echo "Using WorldAddress: $worldAddress"

# Build the command
command="forge script RegisterApp.s.sol --sig 'run(address)' --broadcast --legacy --rpc-url ${rpcUrl} -- ${worldAddress}"

echo "Running script: $command"
eval "$command"
