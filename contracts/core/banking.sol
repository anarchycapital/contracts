// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../AkapzTokenFlatten.sol";
import "../wallets/AcapzFoundersWallet.sol";

contract Banking {

    AkapzToken private token;

    AkapzToken private stakingToken;

    uint256 private _totalTokens;
    uint256 private _totalStakingToken;
    uint256 private _minTokenValue;
    uint256 private _minStakingTokenValue;

    address private _bankVault;

    function initBankingServices(address[] memory members, string[] memory names) private returns(address) {
        AcapzFoundersWallet commitee = new AcapzFoundersWallet(address(this));
        commitee.init(members, names);
        _bankVault = address(commitee);
        token.mint(_bankVault, _totalTokens);
        return _bankVault;
    }

    function createBankCurrencies() private  {
        token = new AkapzToken();
        _totalTokens = token.totalSupply();
        stakingToken = new AkapzToken();
    }

    function vault() public view virtual returns(address) {
        return _bankVault;
    }

    function vaultBalance() public view virtual returns(uint256) {
        return token.balanceOf(_bankVault);
    }

    


}