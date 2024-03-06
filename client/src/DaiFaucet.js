import React from 'react';



function DaiFaucet( { contracts, user} ){

    const getDai = async(amount)=>{
        const rawTokens = await contracts.splitBag.methods.getTokens().call();

        console.log(rawTokens);
        await contracts.dai.methods.faucet( user, amount).send({from: user});
        await contracts.dai.methods.approve(
          contracts.SplitBag.address, 
          amount, 
          {from: user}
        ).send({from:user});  
    }
    
    return(
        <button className="btn btn-primary" onClick={()=>getDai(100)}>Get 100 DAI</button>
    );
}

export default DaiFaucet;