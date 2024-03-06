import React from "react";


function Vaults({Vaults, title}) {
/*
    const renderAllSplitLine = (splits) => {
        for(var i =0 ;i<splits.length, i++;){
               render1SplitLine(splits[i]);
        }      
    }
*/
    const displayVaults = (Vaults)=> {
          if (Vaults!=='undefined'){
            return (  
              Vaults.map((split) =>(
                   <tr key={split.id} >
                     <td>{split.VaultId}</td>
                     <td>{split.from}</td>                      
                     <td>{split.amount}</td>
                     <td>{split.part}</td>                       
                     <td>{split.splitId}</td>                       
                   </tr>
                )));

          }
          return '';   
    }

    return (
        <div id="order-list" className="card">      
    
          <h2 className="card-title"> {title}</h2>
          <div className="row">
            <div className="col-sm-6">
            
            </div>
                <table className={"table table-striped mb-0 order-list"}>
                <thead>       
                <tr>
                    <th>id</th>
                    <th>From</th>
                    <th>Amount</th>
                    <th>Part</th>
                    <th>SplitOwner</th>
                </tr>
                </thead>        
                <tbody>
                 
                  {displayVaults(Vaults)}  

                </tbody>  
            </table>
          </div>
        </div>
        
      );
}

export default Vaults;