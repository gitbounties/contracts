default: deploy-anvil

deploy-anvil:
  forge script script/DeployLocal.s.sol:DeployLocalScript --fork-url http://localhost:8545 --broadcast

