const SplitVault = artifacts.require("SplitVault.sol");
const VaultFactory = artifacts.require('VaultFactory.sol');
const BagMain = artifacts.require('BagMain.sol');
const Dai = artifacts.require("Mocks/Dai.sol")
const Pep = artifacts.require("Mocks/PEp.sol")
const Side = artifacts.require("Mocks/Side.sol")
const BagStruct = artifacts.require("libraries/BagStruct.sol")
const SwapRouterMock = artifacts.require('mocks/SwapRouterMock.sol');
//const TransferHelperMock = artifacts.require('@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol');

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


    
    const bagStruct = await BagStruct();
    BagStruct.setasDeployed(bagStruct);

    
    
    const swapRouterMock = await SwapRouterMock.new();
    SwapRouterMock.setasDeployed(swapRouterMock);

    const WETHAddr= "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const DAIAddr= "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const LINKAddrr= "0x514910771af9ca656af840dff83e8264ecf986ca";


    const bagMain = await BagMain.new(["WETH","DAI", "LINK"],[WETHAddr,DAIAddr,LINKAddrr],swaprouter, supraOracleMock.address,bagStruct);
    BagMain.setasDeployed(bagMain);
}
