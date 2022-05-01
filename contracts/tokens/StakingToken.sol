//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "../core/staking.sol";


contract StakingToken is Initializable, UUPSUpgradeable, ContextUpgradeable, AccessControlEnumerableUpgradeable, IERC20MetadataUpgradeable, ERC20BurnableUpgradeable, ERC20CappedUpgradeable, ERC20PausableUpgradeable, Staking {

    function stake(uint256 _amount) public {
        // @notice Make sure staker actually is good for it
        require(_amount < _balances[msg.sender], "StakingToken: Cannot stake more than you own");

        _stake(_amount);
        // @notice Burn the amount of tokens on the sender
        _burn(msg.sender, _amount);
    }

    /**
       * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdraw(uint256 _amount, uint256 stakeIndex) public onlyStaker(stakeIndex) {

    uint256 amount_to_mint = _withdrawStake(amount, stake_index);
        // Return staked tokens to user
        _mint(msg.sender, amount_to_mint);
    }

}
