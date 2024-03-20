// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import {XRING} from "../src/XRING.sol";
import {XRINGLockBox} from "../src/XRINGLockBox.sol";

contract XRINGLockBoxTest is Test {
    using Chains for uint256;

    RING ring = RING(0x9469D013805bFfB7D3DEBe5E7839237e535ec483);
    XRING xRING;
    XRINGLockBox lockbox;

    address guy;
    address him;

    function setUp() public {
        uint256 chainId = Chains.Ethereum;
        vm.createSelectFork(chainId.toChainName());

        xRING = new XRING();
        lockbox = new XRINGLockBox(address(ring), address(xRING));

        guy = address(new Guy());
        him = address(new Guy());
        mint_xring_to(guy, 1);
        mint_ring_to(him, 1);

        xRING.mint(address(lockbox), ring.totalSupply());
        address[] memory allowList = new address[](1);
        allowList[0] = address(lockbox);
        address authority = address(new RINGAuthority(allowList));
        vm.prank(ring.owner());
        ring.setAuthority(authority);
    }

    function test_contructor_args() public {
        assertEq(xRING.name(), "Darwinia Network xRING");
        assertEq(xRING.symbol(), "xRING");
        assertEq(xRING.decimals(), 18);
    }

    function invariant_totalSupply() public {
        assertEq(xRING.balanceOf(address(lockbox)), ring.totalSupply());
    }

    function test_deposit() public {
        assertEq(ring.balanceOf(guy), 0);
        assertEq(xRING.balanceOf(guy), 1);
        deposit(guy, 1);
        assertEq(ring.balanceOf(guy), 1);
        assertEq(xRING.balanceOf(guy), 0);
    }

    function test_deposit_for_self() public {
        assertEq(ring.balanceOf(guy), 0);
        assertEq(xRING.balanceOf(guy), 1);
        deposit_for(guy, guy, 1);
        assertEq(ring.balanceOf(guy), 1);
        assertEq(xRING.balanceOf(guy), 0);
    }

    function test_deposit_for_other() public {
        assertEq(ring.balanceOf(him), 1);
        assertEq(xRING.balanceOf(guy), 1);
        deposit_for(guy, him, 1);
        assertEq(ring.balanceOf(him), 2);
        assertEq(xRING.balanceOf(guy), 0);
    }

    function test_withdraw() public {
        assertEq(ring.balanceOf(him), 1);
        assertEq(xRING.balanceOf(him), 0);
        withdraw(him, 1);
        assertEq(ring.balanceOf(him), 0);
        assertEq(xRING.balanceOf(him), 1);
    }

    function test_withdraw_to_self() public {
        assertEq(ring.balanceOf(him), 1);
        assertEq(xRING.balanceOf(him), 0);
        withdraw_to(him, him, 1);
        assertEq(ring.balanceOf(him), 0);
        assertEq(xRING.balanceOf(him), 1);
    }

    function test_withdraw_to_other() public {
        assertEq(ring.balanceOf(him), 1);
        assertEq(xRING.balanceOf(guy), 1);
        withdraw_to(him, guy, 1);
        assertEq(ring.balanceOf(him), 0);
        assertEq(xRING.balanceOf(guy), 2);
    }

    function test_transfer() public {
        assertEq(xRING.balanceOf(guy), 1);
        assertEq(xRING.balanceOf(him), 0);
        vm.prank(guy);
        xRING.transfer(him, 1);
        assertEq(xRING.balanceOf(guy), 0);
        assertEq(xRING.balanceOf(him), 1);
    }

    function mint_ring_to(address account, uint256 amount) internal {
        vm.prank(ring.owner());
        ring.mint(account, amount);
    }

    function mint_xring_to(address account, uint256 amount) internal {
        vm.prank(xRING.owner());
        xRING.mint(account, amount);
    }

    function deposit(address account, uint256 amount) internal {
        vm.startPrank(account);
        xRING.approve(address(lockbox), amount);
        lockbox.deposit(amount);
        vm.stopPrank();
    }

    function deposit_for(address from, address to, uint256 amount) internal {
        vm.startPrank(from);
        xRING.approve(address(lockbox), amount);
        lockbox.depositFor(to, amount);
        vm.stopPrank();
    }

    function withdraw(address account, uint256 amount) internal {
        vm.startPrank(account);
        ring.approve(address(lockbox), amount);
        lockbox.withdraw(amount);
        vm.stopPrank();
    }

    function withdraw_to(address from, address to, uint256 amount) internal {
        vm.startPrank(from);
        ring.approve(address(lockbox), amount);
        lockbox.withdrawTo(to, amount);
        vm.stopPrank();
    }
}

contract Guy {}

contract RINGAuthority {
    mapping(address => bool) public allowList;

    constructor(address[] memory _allowlists) {
        for (uint256 i = 0; i < _allowlists.length; i++) {
            allowList[_allowlists[i]] = true;
        }
    }

    function canCall(address _src, address, bytes4 _sig)
        public
        view
        returns (bool)
    {
        return (
            allowList[_src]
                && _sig == bytes4(keccak256("mint(address,uint256)"))
        )
            || (
                allowList[_src]
                    && _sig == bytes4(keccak256("burn(address,uint256)"))
            );
    }
}

interface RING {
    function approve(address _spender, uint256 _amount)
        external
        returns (bool success);
    function balanceOf(address src) external view returns (uint256);
    function owner() external view returns (address);
    function mint(address _guy, uint256 _wad) external;
    function setAuthority(address authority_) external;
    function totalSupply() external view returns (uint256);
}
