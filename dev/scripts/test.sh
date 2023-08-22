#!/bin/sh

CONTRACT=0x9A676e781A523b5d0C0e43731313A708CB607508

OP_ADDR=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
U1_ADDR=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
U2_ADDR=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

OP_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
U1_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
U2_KEY=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

tokenId=11

# deploy the contracts (use the operator account to do it)
# PRIVATE_KEY=$OP_KEY OPERATOR_ADDR=$OP_ADDR just

# user 1 mints token and adds some ether into it
echo "mint =-=-=-="
cast send $CONTRACT "mint()" --private-key $U1_KEY
echo "addeth =-=-=-="
cast send $CONTRACT "addETH(uint256)" $tokenId --value 69ether --private-key $U1_KEY

owner=$(cast call $CONTRACT "ownerOf(uint256)" $tokenId)
balance=$(cast b $U1_ADDR)

echo "=-=-=-=-=-="
echo "owner of bounty is $owner"
echo "user 1 has a balance of $balance"

# operator transfers bounty to user 2 and burns it
echo "transfer =-=-=-="
cast send $CONTRACT "transferToken(uint256, address)" $tokenId $U2_ADDR --private-key $OP_KEY
echo "burn =-=-=-="
cast send $CONTRACT "burn(uint256)" $tokenId --private-key $OP_KEY

owner=$(cast call $CONTRACT "ownerOf(uint256)" $tokenId)
balance1=$(cast b $U1_ADDR)
balance2=$(cast b $U2_ADDR)

echo "=-=-=-=-=-="
echo "owner of bounty is $owner"
echo "user 1 has a balance of $balance1"
echo "user 2 has a balance of $balance2"
