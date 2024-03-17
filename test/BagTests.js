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
const WETHAddr = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const PEPEAddr = "0x6982508145454ce325ddbe47a25d4ec3d2311933";
const DAIAddr = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const LINKAddrr = "0x514910771af9ca656af840dff83e8264ecf986ca";
const supraOracles = "0x2FA6DbFe4291136Cf272E1A3294362b6651e8517";


let wethInstance;
let DaiInstance;

contract('BagFactory', accounts => {
    let dai, pep, side, olas, _bagMain, _swapRouterMock, _TranferHelperMock, _supraOracleMock;
    const [trader1, trader2, trader3, trader4, trader5] = [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];

    beforeEach(async () => {

        _supraOracleMock = await SupraOracleMock.new();

        let tokenTick = [stringToBytes32("PEPE"), stringToBytes32("DAI"),stringToBytes32("LINK")];        
        let tokenAddress = [PEPEAddr, DAIAddr, LINKAddrr];
        let tokenSupraIndex = [92, 41, 2];

        let tokens = [
            {ticker:stringToBytes32("PEPE"),tokenAddress:PEPEAddr,chainLinkAddress:"0xDC530D9457755926550b59e8ECcdaE7624181557"},
            {ticker:stringToBytes32("DAI"),tokenAddress:DAIAddr,chainLinkAddress:"0xDC530D9457755926550b59e8ECcdaE7624181557"} ,
            {ticker:stringToBytes32("LINK"),tokenAddress:LINKAddrr,chainLinkAddress:"0xDC530D9457755926550b59e8ECcdaE7624181557"}
        ]
        
        let chainlinkAddr =  ["0xDC530D9457755926550b59e8ECcdaE7624181557","0xDC530D9457755926550b59e8ECcdaE7624181557","0xDC530D9457755926550b59e8ECcdaE7624181557"];

        _bagMain = await BagMain.new(tokens, swaprouter);

        wethInstance = await WETH.at(WETHAddr);
        let amountBefore = await wethInstance.balanceOf(trader1, { from: trader1 });

        DaiInstance = await DAI.at(DAIAddr);
        LINKInstance = await DAI.at(LINKAddrr);

        console.log("swap");
        console.log(amountBefore);

        await wethInstance.deposit({ value: "1100", from: trader1 })      

        let amountAfter = await wethInstance.balanceOf(trader1);

        console.log(trader1);
        console.log(amountAfter);

        const amount = web3.utils.toWei('1000');

        /*
        await dai.faucet(trader1, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader1}
        );

        await dai.faucet(trader2, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader2}
        );

        await dai.faucet(trader3, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader3}
        );

        await dai.faucet(trader4, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader4}
        );

        await dai.faucet(trader5, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader5}
        );
       
        VF.addToken(DAI, dai.address); */
    })


    it('should create a bag', async () => {

        await _bagMain.createBag('babag !', { from: trader1 });

        let allSB = await _bagMain.getAllBags();

        console.log(' tab = > ' + allSB.length);
        console.log('addd ' + allSB[0].addr);
        console.log(allSB);
        assert(allSB.length == 1);
        assert(allSB[0].name == "babag !");
        assert(allSB[0].addr != "0x0");
        assert(allSB[0].from == trader1);
        assert(allSB[0].totalAmount == 0);

        let bagInstance = await Bag.at(allSB[0].addr);
        let tokensCount = await bagInstance.tokensByAddress(WETHAddr);
        console.log('list tokens count ');
        console.log(tokensCount);
        //assert(tokensCount.length>1);

    }, 'échec de la création du SplitVault');


    it.only('should deposit in a bag', async () => {

        await _bagMain.createBag('babag !', { from: trader1 });

        let allSB = await _bagMain.getAllBags();       

        let bag = await Bag.at(allSB[0].addr);
       

        await wethInstance.approve(
            bag.address, 
            "1000", 
            {from: trader1}
        );

        await bag.deposit("100",{from:trader1});        

        let wethAfterDeposit = await wethInstance.balanceOf(allSB[0].addr);
       
        let DAiBagAfterDeposit = await DaiInstance.balanceOf(allSB[0].addr);
        let LinkBagAfterDeposit = await LINKInstance.balanceOf(allSB[0].addr);         
        
        console.log("result");
        console.log(trader1);
        console.log(wethAfterDeposit);       
        console.log(DAiBagAfterDeposit);
        console.log(LinkBagAfterDeposit);

    }, 'échec du dépot du Vault');

    it('should add Token and remove Token', async () => {
        await _bagMain.createBag('babag !', { from: trader1 });

        let allSB = await _bagMain.getAllBags();       

        let bag = await Bag.at(allSB[0].addr);

        //let tokens = await bag.getTokens();
                      
        await bag.removeToken(stringToBytes32("DAI"));
        let tokensAfterRemove = await bag.getTokens();
        assert(tokensAfterRemove.length == 2);
        assert(tokensAfterRemove[0].tokenAddress = PEPEAddr);
        assert(tokensAfterRemove[1].tokenAddress = LINKAddrr);

        tokenTickToAdd = stringToBytes32("BAL"); 
        tokenAddressToAdd =  "0xba100000625a3754423978a60c9317c58a424e3d"
        await bag.addToken(tokenTickToAdd,tokenAddressToAdd, 57);
        let tokensAfterAdd = await bag.getTokens();
        assert(tokensAfterAdd.length == 3);
        assert(tokensAfterAdd[0].tokenAddress = PEPEAddr );
        assert(tokensAfterAdd[1].tokenAddress = LINKAddrr  );
        assert(tokensAfterAdd[2].tokenAddress = tokenAddressToAdd  );


    }, 'échec du retrait');

    function stringToBytes32(str) {
        let hexString = web3.utils.asciiToHex(str);
        let paddedHexString = web3.utils.padRight(hexString, 64); // Ensure it's 32 bytes long
        return paddedHexString;
    }
}

);


