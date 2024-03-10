require("@nomiclabs/hardhat-truffle5");

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
    hardhat :{},
    sepolia: {
        url : "https://ethereum-sepolia-rpc.publicnode.com",
        accounts: "remote"
        
      }
  },
  
};