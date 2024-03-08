const Bag = artifacts.require('Bag.sol');
const truffleAssert = require('truffle-assertions');

const BagMain = artifacts.require('BagMain.sol');
const Dai = artifacts.require('mocks/Dai.sol');
const Pep = artifacts.require('mocks/Pep.sol');
const Side = artifacts.require('mocks/Side.sol');
const Ola = artifacts.require('mocks/Ola.sol');

const SupraOracleMock = artifacts.require('mocks/supraOracleMock.sol');
const SwapRouterMock = artifacts.require('mocks/SwapRouterMock.sol');
const TransferHelperMock = artifacts.require('libraries/TransferHelper.sol');

contract('BagFactory' , accounts =>{
    let dai, pep, side , olas , _bagMain, _swapRouterMock, _TranferHelperMock, _supraOracleMock;
    const [trader1, trader2, trader3, trader4, trader5]=[accounts[0], accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];
    const DAI = web3.utils.fromAscii('DAI'); 
    const OLA = web3.utils.fromAscii('OLA'); 
    
    
    beforeEach(async ()=>{
       
       
        dai = await Dai.new(); 
        pep = await Pep.new(); 
        side = await Side.new(); 

        olas = await Ola.new();

        _swapRouterMock = await SwapRouterMock.new();
        _supraOracleMock = await SupraOracleMock.new();
        tokenTick = ["DAI","PEP","SIDE"];
        tokenAddress = [dai.address, pep.address, side.address];
        _bagMain = await BagMain.new(tokenTick, tokenAddress,_swapRouterMock.address, _supraOracleMock.address);
        

        const amount = web3.utils.toWei('1000');

        await dai.faucet(trader1, amount)
        await dai.approve(
            _bagMain.address, 
            amount, 
            {from: trader1}
        );

        await pep.faucet(trader1, amount)
        await pep.approve(
            _bagMain.address, 
            amount, 
            {from: trader1}
        );

        await side.faucet(trader1, amount)
        await side.approve(
            _bagMain.address, 
            amount, 
            {from: trader1}
        );

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
  

    it('should create a bag', async ()=>{
      
        await _bagMain.createBag('babag !',{from:trader1});
      
        let allSB =  await _bagMain.getAllBags(); 
        
        console.log(' tab = > ' + allSB.length);
        console.log('addd '  + allSB[0].addr);
        console.log(allSB);
        assert(allSB.length ==1);
        assert(allSB[0].name == "babag !");
        assert(allSB[0].addr != "0x0");
        assert(allSB[0].from == trader1);        
        assert(allSB[0].totalAmount == 0);

        
    }, 'échec de la création du SplitVault');


    it.only('should deposit in a bag', async()=>{
        
        await _bagMain.createBag('babag !',{from:trader1});
      
        let allSB =  await _bagMain.getAllBags(); 

       
        let bag = await Bag.at(allSB[0].addr);
        await truffleAssert.reverts(bag.deposit("100",olas.address),"Token not available");
        bag.deposit("100",Dai.address);
        console.log("after");
         
        

    }, 'échec du dépot du Vault');


    it('should buys tokens when fund are received', async()=>{

        await _bagMain.createBag('babag !',{from:trader1});
      
        let allSB =  await _bagMain.getAllBags(); 
        
        console.log(' tab = > ' + allSB.length);
        console.log('addd '  + allSB[0].addr);
        console.log(allSB);
        


    }, 'échec du retrait');
    
}


);


