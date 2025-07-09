# To load the variables in the .env file
source .env

# Check command line arguments
if [ "$1" = "deploy" ]; then
    # Deploy new contract
    forge script script/Deploy.s.sol:Deploy \
        --rpc-url $RPC_URL \
        --broadcast \
        --verify \
        --etherscan-api-key $ETHERSCAN_API_KEY \
        -vvvv
elif [ "$1" = "upgrade" ]; then
    # Upgrade existing proxy
    forge script script/Deploy.s.sol:Deploy \
        --sig "upgrade(address,address)" $PROXY_ADDR $PROXY_ADMIN_ADDR \
        --rpc-url $RPC_URL \
        --broadcast \
        --verify \
        --etherscan-api-key $ETHERSCAN_API_KEY \
        -vvvv
else
    echo "Usage:"
    echo "  ./deploy.s.sh deploy      - Deploys new implementation and proxy"
    echo "  ./deploy.s.sh upgrade     - Upgrades existing proxy"
    exit 1
fi
