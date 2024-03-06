import React from "react";


function Tips({tips, title}) {
/*
    const renderAllSplitLine = (splits) => {
        for(var i =0 ;i<splits.length, i++;){
               render1SplitLine(splits[i]);
        }      
    }
*/
    const displayVaults = (Vaults)=> {
          if (tips!='undefined'){
            return (  
                tips.map((tip) =>(
                   <tr key={tip.id + tip.vaultFor} >
                     
                     <td>{tip.from}</td>                      
                     <td>{tip.amount}</td>
                     <td>{tip.VaultFor}</td>                       
                                          
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
                    
                    <th>From</th>
                    <th>Amount</th>                   
                    <th>SplitOwner</th>
                </tr>
                </thead>        
                <tbody>
                 
                  {displayVaults(tips)}  

                </tbody>  
            </table>
          </div>
        </div>
        
      );
}

export default Tips;