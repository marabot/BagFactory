// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract Side is ERC20  {
  constructor() ERC20('SIDE', 'SIDE bullish project')  {}

  function faucet(address to, uint amount) external {
    _mint(to, amount);
  }
}
