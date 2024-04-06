
import React, {useState} from "react";


function NewBag({createBag,closePopupCreate}){

    const [name, setName] = useState('');
    const [receiver, setReceiver] = useState('');

    

    const createBagfunct = async()=>{                    
        await createBag(name);
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
          </div>         
          
          <div className="text-right">
             <button className="btn btn-primary" onClick={()=>createBagfunct()}>Create SplitVault</button>
          </div>
      </div>
    );
}

export default NewBag;