<div align="center">

# contracts

smart contracts for gitbounties

<div>

## Running for development

Build contracts
```sh
forge build
```

## Deploying on anvil test net

Start an anvil test net instance
```sh
anvil
```

Grab a private key that is outputted and run the following
```sh
PRIVATE_KEY=<private_key> just deploy-anvil
```

You can now use cast to interact with deployed contracts. For example, we can first mint a new NFT
```sh
cast send <nft-contract-addr> "mint()" --private-key <private_key>
```

Then we can check the owner of the NFT
```sh
cast call <nft-contract-addr> "ownerOf(uint256)" 1
```
