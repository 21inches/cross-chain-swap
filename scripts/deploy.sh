#!/bin/zsh

set -e # exit on error

# Source the .env file to load the variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# --- Configuration ---
# The primary contract you are deploying.
# This makes it easier to change in the future.
CONTRACT_TO_DEPLOY="EscrowFactory"

# Define the chain configurations
typeset -A chains
chains["mainnet"]="$MAINNET_RPC_URL"
chains["bsc"]="$BSC_RPC_URL"
chains["polygon"]="$POLYGON_RPC_URL"
chains["avalanche"]="$AVALANCHE_RPC_URL"
chains["gnosis"]="$GNOSIS_RPC_URL"
chains["arbitrum"]="$ARBITRUM_RPC_URL"
chains["optimism"]="$OPTIMISM_RPC_URL"
chains["base"]="$BASE_RPC_URL"
chains["zksync"]="$ZKSYNC_RPC_URL"
chains["linea"]="$LINEA_RPC_URL"
chains["sonic"]="$SONIC_RPC_URL"
chains["unichain"]="$UNICHAIN_RPC_URL"
# For Tron, the RPC URL is mainly for tronbox.js, not forge
chains["tron"]="$TRON_RPC_URL"
chains["nile"]="$NILE_RPC_URL" # Nile is a testnet for Tron


# --- Input Validation ---
CHAIN="$1"
if [ -z "$CHAIN" ]; then
    echo "Error: No chain specified."
    echo "Usage: ./scripts/deploy.sh <chain_name> [keystore_file]"
    exit 1
fi

rpc_url="${chains["$CHAIN"]}"
if [ -z "$rpc_url" ]; then
    echo "Chain '$CHAIN' not found or its RPC URL is not set in .env"
    exit 1
fi
echo "Provided chain: $CHAIN"
echo "RPC URL: $rpc_url"


# --- Main Deployment Logic ---

# Handle Tron mainnet and testnet as a special case
if [ "$CHAIN" = "tron" ] ||  [ "$CHAIN" = "nile" ]; then
    echo "Detected Tron chain. Beginning deployment process with TronBox..."

    # Check for jq dependency
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install it to process Foundry artifacts."
        exit 1
    fi

    # Define directories and paths
    FOUNDRY_BUILD_DIR="out/${CONTRACT_TO_DEPLOY}.sol"
    TRONBOX_DIR="tronbox"
    TRONBOX_BUILD_DIR="$TRONBOX_DIR/build/contracts"
    FOUNDRY_ARTIFACT_PATH="$FOUNDRY_BUILD_DIR/$CONTRACT_TO_DEPLOY.json"

    # 1. Build contracts with Foundry
    echo "\n[Step 1/4] Building contracts with Foundry..."
    forge build
    echo "Build complete."

    # 2. Prepare TronBox directories
    echo "\n[Step 2/4] Preparing TronBox directories..."
    mkdir -p "$TRONBOX_BUILD_DIR"
    echo "Directories are ready."

    # 3. Transform and copy artifacts for TronBox
    echo "\n[Step 3/4] Creating TronBox-compatible artifact..."
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
    echo "Artifacts ready for TronBox."

    # 4. Deploy using TronBox
    echo "\n[Step 4/4] Deploying contracts to Tron using TronBox..."
    # Assumes a "tron" network is configured in your tronbox.js
    (cd "$TRONBOX_DIR" && tronbox migrate --network $CHAIN --reset)
    echo "\nSuccessfully deployed to Tron!"

# Handle all other EVM-based chains
else
    echo "🚀 Detected EVM chain. Beginning deployment process with Foundry..."

    KEYSTORE_FILE="$2"
    if [ -z "$KEYSTORE_FILE" ]; then
        echo "Error: A keystore file must be provided for EVM deployments."
        echo "Usage: ./scripts/deploy.sh $CHAIN <my-keystore.json>"
        exit 1
    fi

    keystore="$HOME/.foundry/keystores/$KEYSTORE_FILE"
    echo "✅ Keystore: $keystore"
    if [ ! -e "$keystore" ]; then
        echo "Error: Keystore not found at the specified path."
        exit 1
    fi

    # Differentiate between zkSync and standard EVM chains
    if [ "$CHAIN" = "zksync" ]; then
        echo "Deploying to zkSync..."
        forge script script/DeployEscrowFactoryZkSync.s.sol --zksync --fork-url "$rpc_url" --keystore "$keystore" --broadcast -vvvv
    else
        echo " Deploying to standard EVM chain..."
        forge script script/DeployEscrowFactory.s.sol --fork-url "$rpc_url" --keystore "$keystore" --broadcast -vvvv
    fi
    echo "\nSuccessfully deployed to $CHAIN!"
fi
