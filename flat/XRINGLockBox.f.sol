// hevm: flattened sources of src/XRINGLockBox.sol
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

////// lib/zeppelin-solidity/contracts/token/ERC20/IERC20.sol
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/* pragma solidity ^0.8.0; */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

////// src/interfaces/IRING.sol
/* pragma solidity ^0.8.0; */

interface IRING {
    function balanceOf(address src) external view returns (uint256);
    function burn(address _guy, uint256 _wad) external;
    function mint(address _guy, uint256 _wad) external;
}

////// src/XRINGLockBox.sol
/* pragma solidity ^0.8.0; */

/* import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; */
/* import "./interfaces/IRING.sol"; */

contract XRINGLockBox {
    IRING public immutable RING;
    IERC20 public immutable XRING;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    constructor(address ring, address xring) {
        RING = IRING(ring);
        XRING = IERC20(xring);
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _withdraw(msg.sender, amount);
    }

    function depositFor(address to, uint256 amount) external {
        _deposit(to, amount);
    }

    function withdrawTo(address to, uint256 amount) external {
        _withdraw(to, amount);
    }

    function _deposit(address to, uint256 amount) internal {
        XRING.transferFrom(msg.sender, address(this), amount);
        RING.mint(to, amount);
        emit Deposit(to, amount);
    }

    function _withdraw(address to, uint256 amount) internal {
        RING.burn(msg.sender, amount);
        XRING.transfer(to, amount);
        emit Withdrawal(to, amount);
    }
}

