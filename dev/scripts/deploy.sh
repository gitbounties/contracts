#!/bin/sh

OP_ADDR=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720
OP_KEY=0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

PRIVATE_KEY=$OP_KEY OPERATOR_ADDR=$OP_ADDR just

if [ "$#" -ne 2 ]; then
    echo "USAGE deploy.sh <action> <private_key>"
    exit 1
fi


# WARNING: DON'T PUT ACTUAL ADDRESSES HERE
#####
registry_url=""
impl_url=""
#####

# rpc_url="http://127.0.0.1:8545"
rpc_url=${APOTHEM_RPC_URL} # .env

action=${1}
private_key=${2}

case ${action} in
    impl)
        forge create --rpc-url ${rpc_url} \
            --private-key ${private_key} \
            src/Gitbounties6551Implementation.sol:Gitbounties6551Implementation
    ;;
    nft)
        forge create --rpc-url ${rpc_url} \
            --constructor-args ${impl_url} ${registry_url} \
            --private-key ${private_key} \
            src/GitbountiesNFT.sol:GitbountiesNFT
    ;;
    *)
        echo "invalid action"
    ;;   
esac
