
const BagMain = artifacts.require('BagMain.sol');
const BagStruct = artifacts.require("libraries/BagStruct.sol")
const SwapRouterMock = artifacts.require('mocks/SwapRouterMock.sol');
const TokenLib = artifacts.require('libraries/TokenLib.sol');
//const TransferHelperMock = artifacts.require('@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol');

const DAI = web3.utils.fromAscii('DAI');

module.exports = async function (deployer, _network, accounts) {

    const eth = 10^18;
    const [ trader1, trader2, trader3,trader4,_]= accounts;   

    //const tokenlib = await TokenLib.new();
    deployer.deploy(TokenLib);
    //tokenlib =TokenLib.deployed;
    deployer.link(TokenLib, BagMain);

    //const bagStruct = await BagStruct.new();
    //BagStruct.setasDeployed(bagStruct);    
    
  //  const swapRouterMock = await SwapRouterMock.new();
    //SwapRouterMock.setasDeployed(swapRouterMock);

    // Optimism mainnet addresses
    /* 
    const swaprouter = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
    const WETHAddr= "0x4200000000000000000000000000000000000006";
    const AAVEAddr = "0x76FB31fb4af56892A25e32cFC43De717950c9278";
    const DAIAddr = "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1";
    const LINKAddrr = "0x350a791bfc2c21f9ed5d10980dad2e2638ffa7f6";
*/

    // Optimism sepolia addresses
    const swaprouter = "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E";
    const WETHAddr= "0x4200000000000000000000000000000000000006";
    const AAVEAddr = "0x76FB31fb4af56892A25e32cFC43De717950c9278";
    const DAIAddr = "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1";
    const LINKAddrr = "0x350a791bfc2c21f9ed5d10980dad2e2638ffa7f6";

    const oracleAAVE ="0x338ed6787f463394D24813b297401B9F05a8C9d1";
    const oracleDAI = "0x8dBa75e83DA73cc766A7e5a0ee71F656BAb470d6";
    const oracleLINK = "0xCc232dcFAAE6354cE191Bd574108c1aD03f86450";

    let tokens = [
        {ticker:stringToBytes32("AAVE"),tokenAddress:AAVEAddr,chainLinkAddress:oracleAAVE},
        {ticker:stringToBytes32("DAI"),tokenAddress:DAIAddr,chainLinkAddress:oracleDAI}, 
        {ticker:stringToBytes32("LINK"),tokenAddress:LINKAddrr,chainLinkAddress:oracleLINK}
    ]       

    deployer.deploy( BagMain ,tokens,swaprouter);

   // const bagMain = await BagMain.new(tokens,swaprouter);
   // BagMain.setasDeployed(bagMain);

   function stringToBytes32(str) {
    let hexString = web3.utils.asciiToHex(str);
    let paddedHexString = web3.utils.padRight(hexString, 64); // Ensure it's 32 bytes long
    return paddedHexString;
}
}
