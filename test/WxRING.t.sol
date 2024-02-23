// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20PresetMinterPauser, IERC20} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import {WxRING} from "../src/WxRING.sol";

contract WxRINGTest is Test {
    using Chains for uint256;

    WxRING wxRING;
	address guy;
	address RING = 0x9469D013805bFfB7D3DEBe5E7839237e535ec483; 

    function setUp() public {
        uint256 chainId = Chains.Ethereum;
        vm.createSelectFork(chainId.toChainName());
        wxRING = new WxRING();
		guy = address(new Guy());
    }

    function test_contructor_args() public {
		assertEq(wxRING.name(), "Wrapped Darwinia xRING");
		assertEq(wxRING.symbol(), "wxRING");
		assertEq(wxRING.decimals(), 18);
		assertEq(address(wxRING.underlying()), RING);
    }

	function test_deposit_for() public {
		mint_ring_to(guy,1);
		assertEq(IERC20(RING).balanceOf(guy), 1);
		deposit_for(guy, 1);
		assertEq(wxRING.balanceOf(guy), 1);
		assertEq(IERC20(RING).balanceOf(guy), 0);
	}

	function mint_ring_to(address account, uint amount) internal {
		vm.prank(Ownable(RING).owner());
		ERC20PresetMinterPauser(RING).mint(account, amount);
	}

	function deposit_for(address account, uint amount) internal {
		vm.startPrank(account);
		IERC20(RING).approve(address(wxRING), amount);
		wxRING.depositFor(account, amount);
		vm.stopPrank();
	}

	function withdraw_to(address account, uint amount) internal {
		vm.prank(account);
		wxRING.withdrawTo(account, amount);
	}

	function test_withdraw_to() public {
		mint_ring_to(guy,1);
		deposit_for(guy, 1);
		assertEq(wxRING.balanceOf(guy), 1);
		assertEq(IERC20(RING).balanceOf(guy), 0);
		withdraw_to(guy, 1);
		assertEq(wxRING.balanceOf(guy), 0);
		assertEq(IERC20(RING).balanceOf(guy), 1);
	}
}

contract Guy {}
