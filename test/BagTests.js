const Bag = artifacts.require('Bag.sol');
const AggregatorV3Interface = artifacts.require("@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol");
//import { time } from "@nomicfoundation/hardhat-network-helpers";
const iswapRouter = artifacts.require('@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol');

const transferHelper = artifacts.require('@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol');
const helpers = require('@nomicfoundation/hardhat-network-helpers');
const { web3 } = require('hardhat');
//const swapRouterInterface = require('@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol');
const truffleAssert = require('truffle-assertions');

const BagMain = artifacts.require('BagMain.sol');
const DAI = artifacts.require('mocks/Dai.sol');
const Pep = artifacts.require('mocks/Pep.sol');
const Side = artifacts.require('mocks/Side.sol');
const TokenLib = artifacts.require('libraries/TokenLib.sol');
const WETH = artifacts.require('mocks/WETH9.sol');

const SwapForTest = artifacts.require('SwapForTest.sol');


const swaprouter = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const WETHAddr = "0x4200000000000000000000000000000000000006";
const AAVEAddr = "0x76FB31fb4af56892A25e32cFC43De717950c9278";
const DAIAddr = "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1";
const LINKAddrr = "0x350a791bfc2c21f9ed5d10980dad2e2638ffa7f6";

const oracleAAVE ="0x338ed6787f463394D24813b297401B9F05a8C9d1";
const oracleDAI = "0x8dBa75e83DA73cc766A7e5a0ee71F656BAb470d6";
const oracleLINK = "0xCc232dcFAAE6354cE191Bd574108c1aD03f86450";

let wethInstance;
let DaiInstance;

// Définir l'URL de l'API GraphQL d'Uniswap V3
const apiUrl = 'https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3';


contract('BagFactory', accounts => {
    let _bagMain, swapForTest;
    const [trader1, trader2, trader3, trader4, trader5] = [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];

    let tokens = [
        {ticker:stringToBytes32("AAVE"),tokenAddress:AAVEAddr,chainLinkAddress:oracleAAVE},
        {ticker:stringToBytes32("DAI"),tokenAddress:DAIAddr,chainLinkAddress:oracleDAI}, 
        {ticker:stringToBytes32("LINK"),tokenAddress:LINKAddrr,chainLinkAddress:oracleLINK}
    ]       

    beforeEach(async () => {
        
        swapForTest = await SwapForTest.new(swaprouter);
        const tokenlib = await TokenLib.new();

        let AAVEAggregator = await AggregatorV3Interface.at(oracleAAVE);
      
        let AAVEPrice = await AAVEAggregator.latestRoundData();
        console.log("AAVEPrice");
        //console.log(AAVEPrice);
        console.log(BigInt(AAVEPrice[0])/BigInt(Math.pow(10,18)));
        console.log(BigInt(AAVEPrice[2])/BigInt(Math.pow(10,18)));
        console.log(BigInt(AAVEPrice[3])/BigInt(Math.pow(10,18)));
        console.log(AAVEPrice[3]);
        // Lier la bibliothèque au contrat BagMain
        //await BagMain.link("TokenLib", tokenlib.address); 
        BagMain.link(tokenlib);
        _bagMain = await BagMain.new(tokens, swaprouter, WETHAddr);
    
        wethInstance = await WETH.at(WETHAddr);
        let amountBefore = await wethInstance.balanceOf(trader1, { from: trader1 });        

        DaiInstance = await DAI.at(DAIAddr);
        LINKInstance = await DAI.at(LINKAddrr);
        AAVEInstance = await DAI.at(AAVEAddr);

       
        const amount = web3.utils.toWei('1000');      
        await wethInstance.deposit({ value: amount, from: trader1 });
        
       
    })

    it('should create a bag, deposit and retire, and revert if not owner of the bag', async () => {
      
        await _bagMain.createBag('babag !', 10,{ from: trader1 });
        let allSB = await _bagMain.getAllBags();       
        let bag = await Bag.at(allSB[0].addr);       

        await wethInstance.approve(
            bag.address, 
            web3.utils.toWei("0.1"), 
            {from: trader1}
        );

        // Test Deposit
        await truffleAssert.reverts(
            bag.deposit( web3.utils.toWei("0.1"),{from:trader2}),
            "only owner"
        );
      
        await bag.deposit(web3.utils.toWei("0.1"),{from:trader1});        

        wethAfterDeposit = await wethInstance.balanceOf(allSB[0].addr);       
        let DAiBagAfterDeposit = await DaiInstance.balanceOf(allSB[0].addr);
        let LinkBagAfterDeposit = await LINKInstance.balanceOf(allSB[0].addr); 
        let AAVEBagAfterDeposit = await AAVEInstance.balanceOf(allSB[0].addr);     
        
        /*
        console.log("result after deposit :");
        console.log(web3.utils.fromWei(wethAfterDeposit));       
        console.log(web3.utils.fromWei(AAVEBagAfterDeposit));
        console.log(web3.utils.fromWei(DAiBagAfterDeposit));
        console.log(web3.utils.fromWei(LinkBagAfterDeposit));
        */
       
        // Test Retire
        await truffleAssert.reverts(
            bag.retire({from: trader2}),
            "only owner"
        );
        await bag.retire();  
          
        wethAfterDeposit = await wethInstance.balanceOf(allSB[0].addr);     
        DAiBagAfterDeposit = await DaiInstance.balanceOf(allSB[0].addr);
        LinkBagAfterDeposit = await LINKInstance.balanceOf(allSB[0].addr); 
        AAVEBagAfterDeposit = await AAVEInstance.balanceOf(allSB[0].addr); 
        assert(DAiBagAfterDeposit< web3.utils.toWei('0.0001'));
        assert(LinkBagAfterDeposit< web3.utils.toWei('0.0001'));
        assert(AAVEBagAfterDeposit< web3.utils.toWei('0.0001'));
        /*
        console.log("result after retire :");
        console.log(web3.utils.fromWei(wethAfterDeposit));       
        console.log(web3.utils.fromWei(AAVEBagAfterDeposit));
        console.log(web3.utils.fromWei(DAiBagAfterDeposit));
        console.log(web3.utils.fromWei(LinkBagAfterDeposit));
        */

    }, 'Failed Test : create bag, deposit and retire');

    it('should add Token and remove Token, and revert if not owner of the bag', async () => {

        // create Bag
        await _bagMain.createBag('babag !', 10,{ from: trader1 });
        let allSB = await _bagMain.getAllBags();      
        let bag = await Bag.at(allSB[0].addr);        
     
        // test removeToken
        await truffleAssert.reverts(
            bag.removeToken(stringToBytes32("AAVE"), {from : trader2}),
            "only owner"
        );

        await wethInstance.approve(
            bag.address, 
            web3.utils.toWei("0.1"), 
            {from: trader1}
        );
        await bag.deposit(web3.utils.toWei("0.1"),{from:trader1});
        
        await bag.removeToken(stringToBytes32("AAVE"),{from : trader1});
        let tokensAfterRemove = await bag.getTokens();
        assert(tokensAfterRemove.length == 2);
        assert(tokensAfterRemove[0].tokenAddress = DAIAddr);
        assert(tokensAfterRemove[1].tokenAddress = LINKAddrr);
        wethAfterDeposit = await wethInstance.balanceOf(allSB[0].addr); 
        console.log(web3.utils.fromWei(wethAfterDeposit));
        assert(wethAfterDeposit < web3.utils.toWei("0.01"));
        
        // Test AddToken        
       
        await bag.addToken(stringToBytes32("AAVE"),AAVEAddr, oracleAAVE);
        let tokensAfterAdd = await bag.getTokens();
        assert(tokensAfterAdd.length == 3);
        assert(tokensAfterAdd[0].tokenAddress = DAIAddr );
        assert(tokensAfterAdd[1].tokenAddress = LINKAddrr  );
        assert(tokensAfterAdd[2].tokenAddress = AAVEAddr  );      

    }, 'Failed Test : add and remove Token');

    it.only('should rebalance when trigger and prices have changed enough', async () => {
       
        // create Bag
        await _bagMain.createBag('babag !', 10,{ from: trader1 });
        let allSB = await _bagMain.getAllBags();      
        let bag = await Bag.at(allSB[0].addr); 

        await wethInstance.approve(
            bag.address, 
            web3.utils.toWei("10"), 
            {from: trader1}
        );

        await wethInstance.approve(
            swapForTest.address, 
            web3.utils.toWei("900"), 
            {from: trader1}
        );

        await displayBagHoldings(bag, "before deposit");

        await bag.deposit(web3.utils.toWei("0.01"),{from:trader1});

        await displayBagHoldings(bag, "after deposit");

        let prices = await getPricesFromBag(bag);
        console.log(prices);
      


        await swapForTest.swapTokens(web3.utils.toWei('0.5'), WETHAddr, AAVEAddr,{from:trader1});
        await displayBagHoldings(bag,"after swap");
        await AAVEInstance.transfer(bag.address, web3.utils.toWei('0.11'),{from:trader1});

        await displayBagHoldings(bag,"before rebalance");

        let t = await bag.rebalanceIfNeeded();

        await displayBagHoldings(bag, "after rebalance");
       // await helpers.time.increase(3600*24*360);

        let prices2 = await getPricesFromBag(bag);
        console.log(prices2);
      
       
      //  console.log(prices1[0].toString());
       /* let price = await getPrice();
       
        console.log(price);*/
      /*  let pairIDReq = getPairAddressQuery(WETHAddr,AAVEAddr);
        let idPair = await getPairID(pairIDReq);
        console.log("pair ID WETH AAVE  :");
        console.log(idPair);
        let priceReq = getPairInfosQuery(idPair);
        let price = await getPrice(priceReq);
        console.log("prix from uniswap3");
        console.log(price);
*/
        // get price
        // buy for 1000 ETH
        // get price
       /* await displayBagHoldings(bag, "after increase time");

        await bag.rebalanceIfNeeded();

        await displayBagHoldings(bag, "after rebalance");*/

    }, 'Failed Test : should rebalance when trigger');

    function stringToBytes32(str) {
        let hexString = web3.utils.asciiToHex(str);
        let paddedHexString = web3.utils.padRight(hexString, 64); // Ensure it's 32 bytes long
        return paddedHexString;
    }

    async function displayBagHoldings(bag, title){
     //   console.log("bag address");
     //   console.log(bag);
        let wethBag = await wethInstance.balanceOf(bag.address);     
        let DAiBag = await DaiInstance.balanceOf(bag.address);
        let LinkBag = await LINKInstance.balanceOf(bag.address); 
        let AAVEBag = await AAVEInstance.balanceOf(bag.address); 
        let WethBag = await wethInstance.balanceOf(bag.address); 
        let WethBagTrader = await wethInstance.balanceOf(trader1); 
  
        console.log("---------------------------");
        console.log(title);
        console.log("Weth Bag :" + web3.utils.fromWei(WethBag));  
        console.log("WethBagTrader :" + web3.utils.fromWei(WethBagTrader));     
        console.log("AAVE :" + web3.utils.fromWei(AAVEBag));
        console.log("DAI :" +web3.utils.fromWei(DAiBag));
        console.log("LINK :" +web3.utils.fromWei(LinkBag));
        
        console.log("---------------------------");
    }

    async function getPricesFromBag(bag){
        console.log("prix from bag");
        let prices0 = await bag.getPrices();
        
       
    
        let p0 = prices0[0].toNumber()/ (Math.pow(10,8))
        let p1 = prices0[1].toNumber()/ (Math.pow(10,8))
        let p2 = prices0[2].toNumber()/ (Math.pow(10,8))

       /* console.log(prices0[0].toNumber()/ (Math.pow(10,18)));
        console.log(prices0[1].toNumber()/ (Math.pow(10,18)));
        console.log(prices0[2].toNumber()/ (Math.pow(10,18)));*/

        let tokens = await bag.getTokens();
        let t0 = tokens[0].tokenAddress;
        let t1 = tokens[1].tokenAddress;
        let t2 = tokens[2].tokenAddress;
     
        return [{t0,t1,t2},{p0,p1,p2}];
    }

    
}
);


