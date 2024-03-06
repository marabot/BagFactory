// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract Pep is ERC20  {
  constructor() ERC20('PEP', 'PEPE MemeCoin')  {}

  function faucet(address to, uint amount) external {
    _mint(to, amount);
  }


}
