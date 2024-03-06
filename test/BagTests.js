const Bag = artifacts.require('Bag.sol');

const BagMain = artifacts.require('BagMain.sol');
const Dai = artifacts.require('mocks/Dai.sol');

contract('BagFactory' , accounts =>{
    let dai,VF,_bagMain, SB;
    const [trader1, trader2, trader3, trader4, trader5]=[accounts[0], accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];
    const DAI = web3.utils.fromAscii('DAI'); 
    
    
    beforeEach(async ()=>{
       
       
        dai = await Dai.new(); 
        _bagMain = await BagMain.new();
       
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
  

    it('should create a bag', async ()=>{
      
        await _bagMain.createBag('babag !',{from:trader1});
      
        let allSB =  await _bagMain.getAllBags(); 
        
        console.log(' tab = > ' + allSB.length);
        console.log('addd '  + allSB[0].addr);
        console.log(allSB);
        assert(allSB.length ==3);
        assert(allSB[0].name == "babag !");
        assert(allSB[0].addr != "0x0");
        assert(allSB[0].from == trader1);        
        assert(allSB[0].totalAmount == 0);

        
    }, 'échec de la création du SplitVault');


    it('should deposit in a bag', async()=>{
        
        await _bagMain.createBag('babag !',{from:trader1});
      
        let allSB =  await _bagMain.getAllBags(); 
        
        console.log(' tab = > ' + allSB.length);
        console.log('addd '  + allSB[0].addr);
        console.log(allSB);
        assert(allSB.length ==3);
        assert(allSB[0].name == "babag !");
        assert(allSB[0].addr != "0x0");
        assert(allSB[0].from == trader1);        
        assert(allSB[0].totalAmount == 0);



    }, 'échec du dépot du Vault');


    it('should retire', async()=>{

     
    }, 'échec du retrait');
    
}


);


