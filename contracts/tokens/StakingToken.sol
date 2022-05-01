//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "../core/staking.sol";



contract StakingToken is Initializable, ContextUpgradeable, UUPSUpgradeable, OwnableUpgradeable, Staking,ERC20BurnableUpgradeable{

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private _owner;

    constructor() {}

    function initialize(string memory __name, string memory __symbol, uint256 __supply) initializer public  {
        __Context_init_unchained();
        __ERC20_init_unchained(__name, __symbol);

        __ERC20Burnable_init_unchained();
        _owner = msg.sender;
        _totalSupply = __supply * 10 ** decimals();

    }






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
    function withdraw(uint256 _amount, uint256 stakeIndex) public {

    uint256 amount_to_mint = Staking._withdrawStake(_amount, stakeIndex);
        // Return staked tokens to user
        _mint(msg.sender, amount_to_mint);
    }

    function _authorizeUpgrade(address) internal override view onlyOwner {

    }

}
