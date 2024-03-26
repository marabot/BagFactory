
import React, { useState, useEffect } from "react";
import Header from './Header.js';
import TipVault from './TipVaults.js';
import Tips from './Tips.js';
import './Main.css';
import CreateBag from "./CreateBagPopup.js";
import Deposit from "./Deposit.js";
import { Helmet } from "react-helmet";
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { getContracts } from './utils.js';

//function getSplitVault(address sbOwner) external view returns(SplitVault[] memory){       
function App() {

  const [userAddr, setUserAddr] = useState('');
  const [contracts, setContracts] = useState();

  const [web3, setWeb3] = useState([]);
  const [accounts, setAccounts] = useState([]);
  const [Network, setNetwork] = useState([]);
  const [AllVaults, setAllVaults] = useState([]);

  const [MyTipVaults, setMyTipVaults] = useState([]);
  const [MyTips, setMyTips] = useState([]);

  const [showDeposit, setShowDeposit] = useState([]);
  const [DepositVaultAddr, setDepositVaultAddr] = useState([]);

  const [showCreate, setShowCreate] = useState([]);
  const [showWithdraw, setShowWithdraw] = useState([]);

  const [listener, setListener] = useState(undefined);

  // 0 = tipVault     1= tips
  const [menu, setMenu] = useState(0);

  const createSplit = async (_name, _receiver) => {
    //console.log(web3);
    console.log(contracts);
    await contracts.BagMain.methods.createTipVault(_name, _receiver).send({ from: userAddr });
    const AllTipVaults = await contracts.BagMain.methods.getAllTipVaults().call();
    setMyTipVaults(AllTipVaults);
    setShowCreate(false);
  };

  /////////////////////////////    SHOW and HIDE POPUP
  const showPopupDeposit = function (addr) {

    setDepositVaultAddr(addr);

    setShowDeposit(true);
  }

  const closePopupDepo = function () {
    setShowDeposit(false);
  }

  const showCreateCard = function () {
    setShowCreate(true);
  }


  const closePopupCreate = function () {
    setShowCreate(false);
  }

  const closePopupWithdraw = function () {
    setShowWithdraw(false);
  }

  ///////////////////////// COMPONENTs RENDERER
  

  const createComponetRender = function () {
    if (showCreate === true) {
      return (
        <CreateBag
          createSplit={createSplit}
          closePopupCreate={closePopupCreate}
        />
      )
    }
  }

 
  

  const deposit = async (tipVaultAddr, amount) => {
    setDepositVaultAddr(tipVaultAddr);
    try {
      let weiAmount = web3.utils.toWei(amount);
      await contracts.BagMain.methods.tip(tipVaultAddr).send({ from: userAddr, value: weiAmount });
      closePopupDepo();

    } catch (e) {
      alert('error deposit !  ' + e);
    }
  }

  const closeSplit = async (tipVaultAddr) => {
    try {
      await contracts.BagMain.methods.closeTipVault(tipVaultAddr).send({ from: userAddr });

    } catch (e) {
      alert('error closing !' + e);
    }
  }

  const AllVaultRenderer = function () {


    if (web3 == '' || web3 == undefined) {
      return (
        ''
      )
    }
    else {
      return (
        <TipVault
          tip_Vaults={AllVaults}
          title='All Vaults'
          showDeposit={showPopupDeposit}
          showCreate={showCreateCard}
          closeSplit={closeSplit}
          addrUser={userAddr}
          network={Network}
        />
      )
    }
  }



  const text = {
    color: "white",
    textAlign: "center",
    fontSize: 20,
    width: "100%"
  }


  const myVaultsRenderer = function () {

    /// bouton create desactive
    if (web3 == '' || web3 == undefined || MyTipVaults.length == 0) {
      return (
        <div className="card" style={text}>No Vault yet from this address</div>
      )
    }
    else {
      return (
        <TipVault
          tip_Vaults={AllVaults}
          title='your Vaults'
          showDeposit={showPopupDeposit}
          showCreate={showCreateCard}
          closeSplit={closeSplit}
          addrUser={userAddr}
          network={Network}
        />
      )
    }
  }

  const myTipsRenderer = function () {


    if (MyTips.length === 0) {
      return (
        <div className="card" style={text}>No Tip yet from this address</div>
      )
    }
    else {
      return (
        <Tips
          vaults={MyTips}
          title='your Deposits'
        />
      )
    }
  }


  const DisplayMainContent = function () {
    switch (menu) {
      case 0:
        return AllVaultRenderer();
      case 1:
        return myVaultsRenderer();
      case 2:
        return myTipsRenderer();
    }
  }

  const listenToEvents = (thisComponent) => {
    //const tradeIds=new Set();
    // setTrades([]);
    const listenerTipVaultCreated = contracts.BagMain.events.TipVaultCreated({
      fromBlock: 0
    })
      .on('data', () => {

      });
    //setListener(listenerTipVaultCreated);
    setListener(listener);
  }

  function forceUpdateHandler() {
    this.forceUpdate();
  };


  const update = async () => {
    if (web3 != '' && (Network == "11155111" || Network == "1337")) {
      let smartContracts = await getContracts(web3);
      console.log("app 280  smartcontract : ");
      console.log(smartContracts);
      setContracts(smartContracts);

      const acc = accounts[0];
      setUserAddr(acc);
      console.log("app 280  acc: " + acc);
      console.log(contracts);
/*
      const allVaults = await smartContracts.vaultMain.methods.getAllTipVaults().call();
      setAllVaults(allVaults);
      console.log("AllVaults !!!!!!!!!!!!!!!!!")
      console.log(allVaults);

      console.log("app 280 userAddr: " + acc);
      const myTipVaults = await smartContracts.vaultMain.methods.getTipsByOwnerAddr(acc).call();

      setMyTipVaults(allVaults.filter(vault => vault.from == acc));

      console.log("app 280 : " + myTipVaults);
      const myTips = await smartContracts.vaultMain.methods.getTipsByOwnerAddr(acc).call();
      setMyTips(myTips);*/

    }
  };


  useEffect(() => {

    //console.log('useEffect :');
    const init = async () => {

      setShowDeposit(false);
      setShowCreate(false);

    }
    init();

  }, []);


  useEffect(() => {

    update();

  }, [accounts]);


  const styleBack = {
    color: "white",
    fontSize: 30,
    width: "100%"
  }

  const boutonMenu = {
    color: "white",
    backgroundColor: "#00225520",
    borderColor: "#ffffff",
    fontSize: 15,
    width: "150px"
  }

  const paddingRow = {
    textAlign: "center",
    padding: '50px'
  }

  const setMenuIndex = (index) => {
    setMenu(index);
  }


  return (
    <div id="app" style={styleBack}>
      <Helmet>
      </Helmet>

      <Header

        setWeb3={setWeb3}
        setAccounts={setAccounts}
        setNetwork={setNetwork}
      />
      <Row style={paddingRow}>
      
        <Col className="col-sm-4"><div ><button id="boutMenuBag" className="btn btn-primary" style={boutonMenu} onClick={() => setMenuIndex(1)}>your Bags</button></div></Col>
       
      </Row>
      <Row>
        <Col className="col-sm-2"></Col>
        <Col className="col-sm-8">

          {DisplayMainContent()}
        </Col>
        <Col className="col-sm-2"></Col>

      </Row>
      {createComponetRender()}
     

    </div>
  );
}

export default App;

