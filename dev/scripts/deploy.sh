#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "USAGE deploy.sh <action> <private_key>"
    exit 1
fi


# WARNING: DON'T PUT ACTUAL ADDRESSES HERE
#####
registry_url=""
impl_url=""
#####

rpc_url="http://127.0.0.1:8545"

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
    registry)
        forge create --rpc-url ${rpc_url} \
            --private-key ${private_key} \
            src/ERC6551Registry.sol:ERC6551Registry
    ;;
    *)
        echo "invalid action"
    ;;   
esac
