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
        url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
        blockNumber: 19406433
        
      },
    },
    sepolia: {
        url : "https://ethereum-sepolia-rpc.publicnode.com",
        accounts: "remote"
        
      }
  },
  
};