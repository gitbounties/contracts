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
