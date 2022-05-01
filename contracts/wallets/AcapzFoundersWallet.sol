// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../core/secureTokenTransfer.sol";
import "../tokens/AkapzToken.sol";
contract AcapzFoundersWallet is SecureTokenTransfer, Context, Ownable {
    

    using Address for address;
    using SafeMath for uint256;

    address private _owner;

    uint256 public nonce;
    uint256 private threshold = 0;

    struct Founder  {
        address _founderAddress;
        string _name;
        string _pos;
        string _contact;
        bool canSignTx;
    }

    mapping(address => bool) private isFounder;
    mapping(address => bool) private canSign;
    mapping(address => Founder) private founderData;
    mapping(address => bool) private founderInWallet;

    event FounderAdded(address indexed founder, string founderName);
    event FounderRemoved(address indexed founder);

    mapping(uint256 => Founder) public founders;
    // @dev founder zero is the owner of the contract cannot be called or sign
    uint internal count= 0;

    mapping(address => uint) private foundersId;

    bool private initialized = false;

    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH = keccak256(abi.encodePacked("EIP712Domain(uint256 chainId, address verifyingContract"));
    bytes32 private constant SAFE_TX_TYPEHASH = keccak256(abi.encodePacked( "SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)"));

    bool private lockedStatus = false;


    constructor(address  __ownerZero) {
        threshold = 1;
        // @dev will set founder zero as owner of the contract
        founders[0] = Founder({
            _founderAddress: __ownerZero,
            _name: "owner zero",
            _pos: "contract owner",
            _contact: "none",
            canSignTx: false
        });
        count = 1;

        _owner = founders[0]._founderAddress;


    }

    function init(address[] calldata _founders, string[] calldata _names) external notInitialized {
        uint i = 0;
        for (i == 0; i < _founders.length; i++) {
            addFounder(_founders[i], _names[i], "founder", "none", true);
        }
        initialized = true;
    }

    function addFounder(address founder, string memory __name, string memory __pos, string memory __contact, bool canSignTx) public onlyOwner founderDoesNotExists(founder) {

        founders[count]= Founder({
            _founderAddress:founder,
            _name: __name,
            _pos:__pos,
            _contact: __contact,
            canSignTx: canSignTx});

            foundersId[founder] = count;

            count = count+1;
            emit FounderAdded(founder, __name);

    }

    function getFounderByAddress(address founderAddress) public view founderExists(founderAddress) returns(Founder memory) {
        require(founderAddress != address(0), "address zero is not a founder");
        uint256 fid = foundersId[founderAddress];
        require(fid != 0, "cannot call founder zero");

        return founders[fid];
    }

    modifier isNotFounderZero() {
        require(foundersId[msg.sender] != 0, "cannot use founder zero for op");
        _;
    }

    modifier founderDoesNotExists(address founder) {
        require(!isFounder[founder]);
        _;
    }

    modifier founderExists(address founder) {
        require(isFounder[founder]);
        _;
    }

    modifier notInitialized() {
        require(!initialized, "already initialized");
        _;
    }

    function getOwner()  public virtual view returns(address) {
        return _owner;
    }

    receive() external payable {
        if(msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

   event Deposit(address indexed sender, uint value);

   function assignFundsToFounders(address token, address[] memory __founders, uint256[] memory values) public onlyOwner {

       uint i = 0;
       for(i == 0; i < __founders.length; i++) {
           _assignFunds(token, __founders[i], values[i]);
       }

   }

   function _assignFunds(address token, address _founder, uint256 amt) private founderExists(_founder) {
       SecureTokenTransfer.transferToken(token, _founder, amt);
   }


}