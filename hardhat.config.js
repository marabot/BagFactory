require("@nomiclabs/hardhat-truffle5");
require('dotenv').config();

module.exports = {
  solidity: {
    version: '0.8.19',
    optimizer: {
      enabled: true,
      runs: 1
    }
  },  
  sources: "client/src/contracts",
  networks: {
    hardhat :{
        forking: {
        enabled: true,        
        url: `https://opt-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
        blockNumber: 19406433,
        accounts: [
          "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
          "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
          "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
        ]
        
      },
    },
    sepolia: {
        url : "https://ethereum-sepolia-rpc.publicnode.com",
        accounts: "remote"
        
      }
   
  },
  
};