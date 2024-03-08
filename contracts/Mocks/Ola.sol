// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract Ola is ERC20  {
  constructor() ERC20('OLA', 'OLAS coin')  {}

  function faucet(address to, uint amount) external {
    _mint(to, amount);
  }
}
