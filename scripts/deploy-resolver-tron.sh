#!/bin/zsh

set -e # exit on error

# Source the .env file to load the variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create one with TRON_RPC_URL and NILE_RPC_URL."
    exit 1
fi

# --- Configuration for Resolver Contract Deployment ---
CONTRACT_TO_DEPLOY="Resolver"
CONTRACT_SOURCE_PATH="contracts/Resolver.sol" # The full path to your contract file within your project

# Define the Tron chain configurations
typeset -A chains
chains["tron"]="$TRON_RPC_URL" # Mainnet
chains["nile"]="$NILE_RPC_URL" # Nile Testnet

# --- Input Validation ---
CHAIN="$1"
if [ -z "$CHAIN" ]; then
    echo "Error: No Tron chain specified."
    echo "Usage: ./scripts/deploy-resolver-tron.sh <tron_network>"
    echo "  <tron_network> can be 'tron' (mainnet) or 'nile' (testnet)."
    exit 1
fi

rpc_url="${chains["$CHAIN"]}"
if [ -z "$rpc_url" ]; then
    echo "Error: Tron chain '$CHAIN' not found or its RPC URL is not set in .env."
    echo "Available Tron chains: tron, nile"
    exit 1
fi
echo "Provided Tron chain: $CHAIN"
echo "RPC URL: $rpc_url"

# --- Dependency Checks ---
if ! command -v forge &> /dev/null; then
    echo "Error: Foundry 'forge' command not found. Please install Foundry."
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it (e.g., brew install jq, sudo apt-get install jq)."
    exit 1
fi
if ! command -v tronbox &> /dev/null; then
    echo "Error: 'tronbox' command not found. Please install TronBox (npm install -g tronbox)."
    exit 1
fi

# --- Main Deployment Logic for Tron ---
echo "Detected Tron chain: '$CHAIN'. Beginning deployment process for '$CONTRACT_TO_DEPLOY' with TronBox..."

# Define directories and paths
# Foundry outputs artifacts to out/ContractName.sol/<ContractName>.json
FOUNDRY_ARTIFACT_PATH="out/$CONTRACT_TO_DEPLOY.sol/$CONTRACT_TO_DEPLOY.json"
TRONBOX_DIR="tronbox"
TRONBOX_BUILD_DIR="$TRONBOX_DIR/build/contracts"

# 1. Build contracts with Foundry
echo "\n[Step 1/4] Building contracts with Foundry..."
forge build
echo "Foundry build complete."

# Check if the expected Foundry artifact exists
if [ ! -f "$FOUNDRY_ARTIFACT_PATH" ]; then
    echo "Error: Foundry artifact not found at '$FOUNDRY_ARTIFACT_PATH'."
    echo "Please ensure '$CONTRACT_TO_DEPLOY' is correctly defined and compiles successfully."
    exit 1
fi

# 2. Prepare TronBox directories
echo "\n[Step 2/4] Preparing TronBox directories..."
mkdir -p "$TRONBOX_BUILD_DIR"
echo "Directories are ready."

# 3. Transform and copy artifacts for TronBox
echo "\n[Step 3/4] Creating TronBox-compatible artifact for '$CONTRACT_TO_DEPLOY'..."
ABI=$(jq '.abi' "$FOUNDRY_ARTIFACT_PATH")
# IMPORTANT FIX: Foundry's bytecode object already includes "0x".
# Adding another one (`0x$BYTECODE`) will cause errors.
BYTECODE=$(jq -r '.bytecode.object' "$FOUNDRY_ARTIFACT_PATH")

cat > "$TRONBOX_BUILD_DIR/$CONTRACT_TO_DEPLOY.json" <<EOF
{
  "contractName": "$CONTRACT_TO_DEPLOY",
  "abi": $ABI,
  "bytecode": "$BYTECODE"
}
EOF
echo "Artifact for '$CONTRACT_TO_DEPLOY' ready for TronBox at '$TRONBOX_BUILD_DIR/$CONTRACT_TO_DEPLOY.json'."

# 4. Deploy using TronBox
echo "\n[Step 4/4] Deploying '$CONTRACT_TO_DEPLOY' to Tron using TronBox..."
echo "IMPORTANT: Ensure you have a migration script in 'tronbox/migrations/' (e.g., '2_deploy_resolver.js')"
echo "that imports and deploys the '$CONTRACT_TO_DEPLOY' contract."
echo "For example:"
echo "  const Resolver = artifacts.require(\"$CONTRACT_TO_DEPLOY\");"
echo "  module.exports = function(deployer) {"
echo "    deployer.deploy(Resolver);"
echo "  };"
echo ""

# Assumes a "tron" or "nile" network is configured in your tronbox.js
(cd "$TRONBOX_DIR" && tronbox migrate --network $CHAIN -f 2 --reset)
echo "\nSuccessfully triggered deployment for '$CONTRACT_TO_DEPLOY' to $CHAIN!"
