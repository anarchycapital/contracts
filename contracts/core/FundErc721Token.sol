// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";


contract FundRepository is ERC1155 {

    constructor(string memory uri_) ERC1155(uri_) {

    }

}

contract FundERC721Factory {

    FundErc721Token private _baseToken;

    struct FundRepositoryItem {
        address tokenAddress;
        uint256 balance;
        uint256 baseFee;
        address creator;
        address owner;
    }

    struct FundMetas {
        string name;
        string logo;
        uint256 supply;
        uint256 goalValue;
        string fundURI;
    }

    mapping(uint256 => FundRepositoryItem) private _repository;
    mapping(uint256 => FundMetas) private _metasRepository;
    mapping(address => bool) private _isFundToken;
    uint private count = 0;

    address private _futureAddress;

    function createFundErc721Token(bytes32 salt) private returns(address) {

        _futureAddress = Clones.predictDeterministicAddress(address(_baseToken), salt);
        address instance = Clones.clone(address(_baseToken));
        _isFundToken[instance] = true;
        return instance;
    }

    function createRepositoryItem(address instance, uint256 balance, uint256 baseFee, address creator, address owner) private returns(uint256) {
        FundErc721Token token = FundErc721Token(instance);
        FundRepositoryItem memory item = FundRepositoryItem({
            tokenAddress: instance,
            balance: balance,
            baseFee: baseFee,
            creator: creator,
            owner: owner
        });

        _repository[count] = item;
        _metasRepository[count] = FundMetas({
            name: token.name(),
            logo: token.name(),
            supply: token.totalSupply(),
            goalValue: 0,
            fundURI: token.tokenURI(count)
        });
        count = count+1;
        return count -1;

    }



}

contract FundErc721Token is  Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable {

        string private _baseTokenURI;
 bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

          constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }


 function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}