const path = require("path");
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    fuji:{
      provider: ()=> new HDWalletProvider(
        process.env.PRIVATE_KEY,
        process.env.INFURA_URL_AVA
         
      ),
        gas: 7000000,
        gasPrice: 470000000000,
        network_id:"*",
        skipDryRun: true
    },
    rinkeby: {
      provider: ()=> new HDWalletProvider(
        process.env.PRIVATE_KEY,
        process.env.INFURA_URL_RINKEBY
      ),
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
    }
    ,
    goerli: {
      provider: ()=> new HDWalletProvider(
        process.env.PRIVATE_KEY_GOERLI,
        process.env.INFURA_URL_GOERLI
      ),
      network_id: 5,
      gasPrice: 100000000,
                
    },
      sepolia: {
      provider: ()=> new HDWalletProvider(
        process.env.PRIVATE_KEY,
        process.env.INFURA_URL_SEPOLIA
      ),
      network_id: 11155111,
      gas: 4500000,
      gasPrice: 10000000000,
                
    }
    ,
    ropsten: {
      provider: function() {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.INFURA_URL_ROBSTEN)
      },
      network_id: 3,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    },

    kovan: {
      provider: function() {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.INFURA_URL_KOVAN)
      },
      network_id: 42,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    },

    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    }
  },

  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  compilers: {
    solc: {
      version: '0.8.0',
      optimizer: {
        enabled: true,
        runs: 1
      }
    }
  }
};
