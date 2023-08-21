/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
const INFURA_API_KEY = "ce70f715ef3a4f49b97e6010bec470d0";

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const PRIVATE_KEY = "6b1bfdbbb86f44378c2333edf36f5342819e305a520fa813c2753c9dfc659325";

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY]
    }
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};
