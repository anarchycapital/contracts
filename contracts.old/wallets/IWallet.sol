//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IWallet {

    string private _walletName;
    string private _walletPurpose;
    address private tokenAddress;
    IERC20 private token;

    uint256 private etherBalance;
    uint256 private tokenBalance;

 
    uint256 private amountAvailableToken;
    uint256 private amountAvailableEth;

    address private _walletOwner;

    address private lockedAssetsWallet;

    mapping(address => uint256) private _transferHistoryEth;
    mapping(address => uint256) private _transferHistoryToken;

    struct Wallet {
        string name;
        string purpose;
        address tokenAddress;
        address owner;
    }

  
    constructor(string memory _name,
    string memory _purpose,
    address _tokenAddr, address owner_) {
         _walletName = _name;
        _walletPurpose = _purpose;
        tokenAddress = _tokenAddr;
        _walletOwner = owner_;
        token = IERC20(tokenAddress);
    }


    function doDeposit(address from, uint256 value) private {

    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

}