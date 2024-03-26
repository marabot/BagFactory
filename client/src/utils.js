import Web3 from 'web3';
import BagMain from './contracts/BagMain.json';
import Bag from './contracts/Bag.json';


const getWeb3 = () => {
  return new Promise((resolve, reject) => {
    // Wait for loading completion to avoid race conditions with web3 injection timing.
    window.addEventListener("load", async () => {
      // Modern dapp browsers...
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        try {
          // Request account access if needed
          await window.ethereum.enable();
          // Acccounts now exposed
          resolve(web3);
        } catch (error) {
          reject(error);
        }
      }
      // Legacy dapp browsers...
      else if (window.web3) {
        // Use Mist/MetaMask's provider.
        const web3 = window.web3;
        console.log("Injected web3 detected.");
        resolve(web3);
      }
      // Fallback to localhost; use dev console port by default...
      else {
        const provider = new Web3.providers.HttpProvider(
          "http://localhost:9545"
        );
        const web3 = new Web3(provider);
        console.log("No web3 instance injected, using Local web3.");
        resolve(web3);
      }
    });
  });
};


const getContracts = async web3 => {
  const chainId = await web3.eth.getChainId();
  // console.log("ds getContracts -  ChainID :" + chainId);
  const networkId = await web3.eth.net.getId();

  //  console.log("ds getContracts -  Network Id :" + networkId);
  const deployedNetwork = BagMain.networks[networkId];
  // console.log("ds getContracts - deployed Network :" + deployedNetwork);
  if (deployedNetwork) console.log("ds getContracts - address :" + deployedNetwork.address);

  const bagMain = new web3.eth.Contract(
    BagMain.abi,
    deployedNetwork && deployedNetwork.address,
  );

  //  console.log(bagMain.options.address);
  // console.log("ds getContracts - contract : " + bagMain.options.jsonInterface + ' -- ' + vaultMain.options.address);

  /* const tipVault = new web3.eth.Contract(
     TipVault.abi,
     deployedNetwork && deployedNetwork.address,
   );
*/
  //const tokens = await bagMain.methods.getTokens().call();
  /*
   const tokenContracts = tokens.reduce((acc, token) => ({
     ...acc,
     [web3.utils.hexToUtf8(token.ticker)]: new web3.eth.Contract(
       ERC20Abi,
       token.tokenAddress
     )
   }), {});*/
  //return { bagMain , ...tokenContracts };
  return { bagMain };
}






const getNetworkId = async web3 => {
  const r = await web3.eth.net.getId();

  return r;
}

export { getWeb3, getContracts, getNetworkId };