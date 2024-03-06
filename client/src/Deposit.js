import React, {useState, useEffect} from "react";


function Deposit({VaultAddr, deposit, closePopupDepo, web3}) {

   const [amount , setAmount]=useState(0);

   const onHandleAmountChange = function(e) {
    let val = e.target.value;

        if (!Number(val) && val!=='') {
            return;
        }
        setAmount(val);
    }

    const depositCall = async()=>{   
     
     
        await deposit(VaultAddr,amount);
    };

    const closePopup = function(){
      closePopupDepo();
    }

    const boutonMenu= {      
     
      fontSize:'20px',
      padding:'20px',
      borderSize:'2px'
    } 

    useEffect(()=>{
        const init = async()=>{
        setAmount('');
        }
        
        init();
        },[]);

    return (
       <div id="newSplit" className="card popup" style={boutonMenu} >
        <div className="closeCross" onClick={closePopup}>X</div>
        <h2 className="card-title">Deposit for {VaultAddr}</h2>   

          <div className="form-group row">
            <label className="col-sm-4 col-form-label" htmlFor="order-amount">Amount</label>
            <div className="col-sm-8">
              <input 
                value={amount}
                type="text" 
                className="form-control" 
                id="name"
                onChange= {e=>onHandleAmountChange(e)}       
              />
            </div>
          </div>         
          
          <div className="text-right">
             <button className="btn btn-primary" onClick={depositCall} >Deposit</button>
          </div>     
        
      </div>
        
      );
}

export default Deposit;