// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import {WxRING} from "../scr/WxRING.sol";

contract WxRINGTest is Test {
    using Chains for uint256;

    WxRING wxRING;
	address RING = 0x9469D013805bFfB7D3DEBe5E7839237e535ec483; 

    function setUp() public {
        uint256 chainId = Chains.Ethereum;
        vm.createSelectFork(chainId.toChainName());
        wxRING = new WxRING();
    }

    function test_contructor_args() public {
		assertEq(wxRING.name(), "Wrapped Darwinia xRING");
		assertEq(wxRING.symbol(), "wxRING");
		assertEq(wxRING.decimals(), 18);
		assertEq(wxRING.underlying(), RING);
    }

	function test_deposit_for() public {
		address guy = address(0x1);
		mint_ring_to(guy,1);
		deposit_for(guy, 1);
		assertEq(wxRING.balanceOf(guy), 1);
	}

	function mint_ring_to(address account, uint amount) internal {
		vm.prank(RING.owner());
		RING.mint(account, amount);
	}

	function deposit_for(address account, uint amount) internal {
		vm.startPrank(account);
		RING.approve(wxRING, amount);
		wxRING.depositFor(account, amount);
		vm.stopPrank(account);
	}

	function withdraw_to(address account, uint amount) internal {
		vm.prank(account);
		wxRING.withdrawTo(account, amount);
	}

	function test_withdraw_to() public {
		address guy = address(0x1);
		mint_ring_to(guy,1);
		deposit_for(guy, 1);
		assertEq(wxRING.balanceOf(guy), 1);
		withdraw_to(guy, 1);
		assertEq(wxRING.balanceOf(guy), 0);
	}
}
