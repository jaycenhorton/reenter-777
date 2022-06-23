// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract Share is ERC777 {
  
    constructor()
        ERC777(
            "SHARE",
            "Share",
            new address[](1)
        )
    {}

    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public {
        _mint(account, amount, userData, operatorData, true);
    }

}
