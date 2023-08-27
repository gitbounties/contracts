default: deploy-anvil

build:
    forge build --via-ir

deploy-anvil:
  forge script script/DeployLocal.s.sol:DeployLocalScript --fork-url http://localhost:8545 --broadcast

