// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/presets/ERC777PresetFixedSupply.sol";

contract ReEnter777 is ERC777PresetFixedSupply {
    constructor()
        ERC777PresetFixedSupply(
            "REN",
            "ReEnter777",
            new address[](1),
            1_000_000,
            msg.sender
        )
    {}
}
