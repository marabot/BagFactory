const SplitVault = artifacts.require("SplitVault.sol");
const VaultFactory = artifacts.require('VaultFactory.sol');
const VaultMain = artifacts.require('VaultMain.sol');
const Dai = artifacts.require("Mocks/Dai.sol")


const DAI = web3.utils.fromAscii('DAI');

module.exports =async function (deployer, _network, accounts) {

    const eth = 10^18;
    const [ trader1, trader2, trader3,trader4,_]= accounts;   

  
    await deployer.deploy(VaultFactory); 
    const vaultFactory = await VaultFactory.deployed()

   

    await deployer.deploy(VaultMain, vaultFactory.address); 
    const vaultMain = await VaultMain.deployed()
/*
    await deployer.deploy(Dai);
    const dai = await Dai.deployed();
    
    
    await vaultMain.addToken(DAI,dai.address);
    const r = await vaultMain.getTokens();
    console.log('tokens =>' + r);
    
    const amount = web3.utils.toWei('1000');
    await dai.faucet(trader1, amount)
    await dai.approve(
      VaultMain.address, 
      amount, 
      {from: trader1}
    );   

    await dai.faucet( trader2, amount)
    await dai.approve(
      VaultMain.address, 
      amount, 
      {from: trader2}
    );   

    

    await dai.faucet(trader3, amount)
    await dai.approve(
      VaultMain.address, 
      amount, 
      {from: trader3}
    );   

    await dai.faucet(trader4, amount)
    await dai.approve(
      VaultMain.address, 
      amount, 
      {from: trader4}
    );   
*/
  //  const amount2 = web3.utils.toWei("50");
/*
    await Spb.createSplitVault('Help for all', {from:trader1}); 
    await Spb.createSplitVault('nom test', {from:trader4});   
    await Spb.deposit(0, 190, {from:trader2}); 
    await Spb.deposit(0, 350, {from:trader3}); 
    await Spb.deposit(0, 250, {from:trader4});   
    await Spb.closeSubSplitVault(0, {from:trader1});*/

}
