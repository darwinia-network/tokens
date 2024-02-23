// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Wrapper, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

contract WxRING is ERC20, ERC20Permit, ERC20Wrapper {
    constructor()
        ERC20("Wrapped Darwinia xRING", "wxRING")
        ERC20Permit("Wrapped Darwinia xRING")
        ERC20Wrapper(IERC20(0x9469D013805bFfB7D3DEBe5E7839237e535ec483))
    {}

    function decimals() public view override(ERC20, ERC20Wrapper) returns (uint8) {
        return super.decimals();
    }
}
