#!/bin/bash

# Set chain ID from environment variable or default to local development
chainId=${CHAIN_ID:-31337}
profile=""

# Set RPC URL based on chain ID
case "${chainId}" in
  "695569")
    rpcUrl="https://rpc.pyropechain.com"
    profile="--profile=pyrope"
    ;;
  "17069")
    rpcUrl="https://rpc.garnetchain.com"
    profile="--profile=garnet"
    ;;
  "690")
    rpcUrl="https://rpc.redstonechain.com"
    profile="--profile=redstone"
    ;;
  *)
    # Default to local development
    rpcUrl="http://127.0.0.1:8545"
    ;;
esac

echo "Using RPC: $rpcUrl"
echo "Using Chain Id: $chainId"

# Extract worldAddress using awk
worldAddress=$(awk -v id="$chainId" -F'"' '$2 == id {getline; print $4}' ../world/worlds.json)

echo "Using WorldAddress: $worldAddress"

command="pnpm mud deploy --worldAddress=$worldAddress --alwaysRunPostDeploy=true --rpcBatch=true $profile"

echo "Running script: $command"
eval "$command"