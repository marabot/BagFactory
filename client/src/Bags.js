import React, {useState, useEffect} from "react";

function Bags({bags, showCreate, showDeposit, closeSplit,withDraw, addrUser, network}) {
    //alert('tip => ' + tip_Vaults[0].endTime + '---' + Date.now());
  
    const deposit = function(addr) {
     
      showDeposit(addr);
    };

    const withdraw = function(id) {
      withDraw(id);
    }

    const create = function() {
      showCreate();
    }
/*
    const closeSplit= function(id){
      closeSplit(id);
    }*/
    const boutDepositRender= function(bag){
      if(bag.endTime > Date.now()/1000)
      {
        return (
          <button className="btn btn-primary" style={boutonMenu} onClick={()=>deposit(bag.addr)}>Deposit</button>
        )

      }else
      {
        return (
          <button className="btn btn-primary disabled" style={boutonMenu} >Closed</button>
        )
      }
    }

    const htmlButtonCloseSplit= function(bag){

     if(bag.from === addrUser) {      
        if(bag.endTime > Date.now()/1000){
          return(
            <div> <button className="btn btn-primary" style={boutonMenu} onClick={()=>closeSplit(bag.addr)}>Close</button></div>
          )
        }else if(bag.endTime==1)
        {
          return(
          <div> <button className="btn btn-primary" style={boutonMenu} onClick={()=>withdraw(bag.addr)}>WithDraw</button></div>
          )
        }else
        {
          return(
            <div> <button style={boutonMenu} className="btn btn-primary disabled"> Delivered </button></div>
            )
        }
      }
    }

 
    function displayTipVaulCard(bag){
        const amountNotWei = bag.totalAmount/ Math.pow(10,18);
        
        
        return (
            <div style={tipVaultCard}>
              <div style={label} >Name</div>
              <div>{bag.name}</div>

              <div style={label}>From</div>
              <div style={adressStye}>{bag.from}</div>

              <div style={label}>Receiver</div>
              <div style={adressStye}>{bag.receiver}</div>
            
              <div style={labelTotalAmount}>Total amount</div>
              <div  >{amountNotWei}</div>
              <div style={boutDeposit} id="btnDeposit">{boutDepositRender(bag)}</div>
              {htmlButtonCloseSplit(bag)}
            </div>

        );
    }

    const tipVaultCard={
      backgroundColor: 'rgb(20, 20, 20,00)',
      borderRadius: '10px',
      border: '4px solid black',
      padding:'20px',
      marginBottom: '1em',
      color: 'white'

    }

    const label= {
        textAlign:"left",
        paddingTop:"7px",      
        fontSize:"18px",      
    }

    const labelTotalAmount= {
      textAlign:"left",
      paddingTop:"7px",      
      fontSize:"20px",      
  }

    const boutDeposit= {
        textAlign:"center",
        fontSize:"8px"       
    }

    const adressStye= {
      textAlign:"left",    
      fontSize:"18px"     
  }

  const space={
    marginBottom:"30px",
    textAlign:'center'
  }

  const boutonMenu= {
    color:"white",
    backgroundColor:"#ddddaa20",
    borderColor:"#ffffff",
    fontSize:15,
    width:"150px"
 }

 const boutonMenuCreate= {
  color:"white",
  backgroundColor:"#00aa0020",
  borderColor:"#ffffff",
  fontSize:15,
  width:"150px"
}


 const header ={
    display:"flex",
    justifyContent:"space-around"
 }

 //if (document.querySelector("#btn-connect"))document.querySelector("#btn-connect").setAttribute("disabled", "disabled");

 //if (document.querySelector("#btn-connect"))document.querySelector("#btn-connect").removeAttribute("disabled");

  useEffect(()=>{
      if (network!="11155111" && network!="1337")
      {
        if (document.querySelector("#btnDeposit")) document.querySelector("#btnDeposit").setAttribute("disabled", "");
        if ( document.querySelector("#btnCreate")) document.querySelector("#btnCreate").setAttribute("disabled", "");
      }else
      {

        if ( document.querySelector("#btnCreate")) document.querySelector("#btnCreate").removeAttribute("disabled");
      }
    }      
   
   ,[]);


    return (
      <div id="order-list" className="card">
         <div style={header}>
                 <div style={space}><button className="btn btn-primary" style={boutonMenuCreate} onClick={()=>create()} id="btnCreate">Create bag</button></div>         
         </div>
          
          
          <div className="row">
            <div className="col-sm-6">              
            </div>
                <div className={"table table-striped mb-0 order-list"}>
                 
               
                { bags.map((bag) =>
                (                  
                    <div key={bag.id}>
                      {displayTipVaulCard(bag)}
                   </div>   
             
                ))}        
               
              </div>
          </div>
      </div>
        
      );
}

export default Bags;