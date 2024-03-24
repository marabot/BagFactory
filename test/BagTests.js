const Bag = artifacts.require('Bag.sol');

const truffleAssert = require('truffle-assertions');

const BagMain = artifacts.require('BagMain.sol');
const DAI = artifacts.require('mocks/Dai.sol');
const Pep = artifacts.require('mocks/Pep.sol');
const Side = artifacts.require('mocks/Side.sol');

const WETH = artifacts.require('mocks/WETH9.sol');

const SupraOracleMock = artifacts.require('mocks/SupraOracleMock.sol');
const SwapRouterMock = artifacts.require('mocks/SwapRouterMock.sol');

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

contract('BagFactory', accounts => {
    let dai, pep, side, olas, _bagMain, _swapRouterMock, _TranferHelperMock, _supraOracleMock;
    const [trader1, trader2, trader3, trader4, trader5] = [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];

    beforeEach(async () => {

        let tokens = [
            {ticker:stringToBytes32("AAVE"),tokenAddress:AAVEAddr,chainLinkAddress:oracleAAVE},
            {ticker:stringToBytes32("DAI"),tokenAddress:DAIAddr,chainLinkAddress:oracleDAI} ,
            {ticker:stringToBytes32("LINK"),tokenAddress:LINKAddrr,chainLinkAddress:oracleLINK}
        ]       

        _bagMain = await BagMain.new(tokens, swaprouter);

        wethInstance = await WETH.at(WETHAddr);
        let amountBefore = await wethInstance.balanceOf(trader1, { from: trader1 });        

        DaiInstance = await DAI.at(DAIAddr);
        LINKInstance = await DAI.at(LINKAddrr);
        AAVEInstance = await DAI.at(AAVEAddr);

        /*console.log("swap");
        console.log(web3.utils.fromWei(amountBefore));*/

        const amount = web3.utils.toWei('1000');
       // await wethInstance.deposit({ value: "100", from: trader1 })   
        await wethInstance.deposit({ value: amount, from: trader1 })      

        let amountAfter = await wethInstance.balanceOf(trader1);

        /*console.log(trader1);
        console.log(web3.utils.fromWei(amountAfter)); */    
    })

    it('should create a bag, deposit and retire, and revert if not owner of the bag', async () => {
      
        await _bagMain.createBag('babag !', { from: trader1 });
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
      
        await bag.deposit( web3.utils.toWei("0.1"),{from:trader1});        

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
        await _bagMain.createBag('babag !', { from: trader1 });
        let allSB = await _bagMain.getAllBags();      
        let bag = await Bag.at(allSB[0].addr);
        
     
        // test removeToken
        await truffleAssert.reverts(
            bag.removeToken(stringToBytes32("AAVE"), {from : trader2}),
            "only owner"
        );
                            
        await bag.removeToken(stringToBytes32("AAVE"),{from : trader1});
        let tokensAfterRemove = await bag.getTokens();
        assert(tokensAfterRemove.length == 2);
        assert(tokensAfterRemove[0].tokenAddress = DAIAddr);
        assert(tokensAfterRemove[1].tokenAddress = LINKAddrr);


        // Test AddToken
        tokenTickToAdd = stringToBytes32("BAL"); 
        tokenAddressToAdd =  "0xba100000625a3754423978a60c9317c58a424e3d"
        await bag.addToken(stringToBytes32("AAVE"),AAVEAddr, oracleAAVE);
        let tokensAfterAdd = await bag.getTokens();
        assert(tokensAfterAdd.length == 3);
        assert(tokensAfterAdd[0].tokenAddress = DAIAddr );
        assert(tokensAfterAdd[1].tokenAddress = LINKAddrr  );
        assert(tokensAfterAdd[2].tokenAddress = AAVEAddr  );


    }, 'Failed Test : add and remove Token');

    function stringToBytes32(str) {
        let hexString = web3.utils.asciiToHex(str);
        let paddedHexString = web3.utils.padRight(hexString, 64); // Ensure it's 32 bytes long
        return paddedHexString;
    }
}

);


