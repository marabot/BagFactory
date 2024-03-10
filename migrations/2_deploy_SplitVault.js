const SplitVault = artifacts.require("SplitVault.sol");
const VaultFactory = artifacts.require('VaultFactory.sol');
const BagMain = artifacts.require('BagMain.sol');
const Dai = artifacts.require("Mocks/Dai.sol")
const Pep = artifacts.require("Mocks/PEp.sol")
const Side = artifacts.require("Mocks/Side.sol")
const SupraOracleMock = artifacts.require('mocks/SupraOracleMock.sol');
const SwapRouterMock = artifacts.require('mocks/SwapRouterMock.sol');
const TransferHelperMock = artifacts.require('libraries/TransferHelper.sol');

const DAI = web3.utils.fromAscii('DAI');

module.exports = async function (deployer, _network, accounts) {

    const eth = 10^18;
    const [ trader1, trader2, trader3,trader4,_]= accounts;   

    /*
    await deployer.deploy(Dai);    
    const dai = await Dai.deployed();
   
    await deployer.deploy(Pep);
    const pep = await Dai.deployed();

    await deployer.deploy(Side);
    const side = await Dai.deployed();

    await deployer.deploy(SwapRouterMock);
    const swapRouterMock = await Dai.deployed();

    await deployer.deploy(SupraOracleMock);
    const supraOracleMock = await Dai.deployed();
  
    await deployer.deploy(BagMain,["dai", "pep", "side"],[dai.address,pep.address,side.address],swapRouterMock.address, supraOracleMock.address); 
    const bagFactory = await BagMain.deployed()
    */


    const dai = await Dai.new();
    Dai.setasDeployed(dai);
    
    const pep = await Pep.new();
    Pep.setasDeployed(pep);
    
    const side = await Side.new();
    Side.setasDeployed(side);
    
    const supraOracleMock = await SupraOracleMock.new();
    SupraOracleMock.setasDeployed(supraOracleMock);
    
    const swapRouterMock = await SwapRouterMock.new();
    SwapRouterMock.setasDeployed(swapRouterMock);

    const bagMain = await BagMain.new(["dai", "pep", "side"],[dai.address,pep.address,side.address],swapRouterMock.address, supraOracleMock.address);
    BagMain.setasDeployed(swapRouterMock);



   

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
