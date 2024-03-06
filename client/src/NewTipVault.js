
import React, {useState} from "react";


function NewSplit({createSplit,closePopupCreate}){

    const [name, setName] = useState('');
    const [receiver, setReceiver] = useState('');

    

    const createSplitVault = async()=>{                    
        await createSplit(name, receiver);
    };
    
    const closePopup = function(){
        closePopupCreate();
    }

    return(
       
        <div id="newSplit" className="card popup">
          <div className="closeCross" onClick={closePopup}>X</div>
        <h2 className="card-title">New Split</h2>   

          <div className="form-group row">
           
            <div className="col-sm-8">
            <div> Name  </div>
              <input 
                value={name}
                type="text" 
                className="form-control" 
                id="name"
                onChange= {e=>setName(e.target.value)}       
              />
            </div>

            <div className="col-sm-12">
              <div>Receiver</div>
              <input 
                value={receiver}
                type="text" 
                className="form-control" 
                id="receiver"
                onChange= {e=>setReceiver(e.target.value)}       
              />
            </div>
          </div>         
          
          <div className="text-right">
             <button className="btn btn-primary" onClick={()=>createSplitVault()}>Create SplitVault</button>
          </div>     
          
        
      </div>
    );
}

export default NewSplit;