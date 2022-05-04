//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract AkapzToken is
    Initializable,
    UUPSUpgradeable,
    ContextUpgradeable,
    AccessControlEnumerableUpgradeable,
    IERC20MetadataUpgradeable,
    ERC20BurnableUpgradeable,
    ERC20CappedUpgradeable,
    ERC20PausableUpgradeable
{
    ISwapRouter public swapRouter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 private _totalBurned;
    uint256 private _totalLocked;
    address private _owner;
    bool private _initializedParams;
    string private _ipfsLogoUrl;

    uint8 private _decimals;
    address public akapz;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event Initialized(string name, address by, uint256 on);

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address owner_,
        uint256 cap_
    ) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __Akapz_Init(name_, symbol_, initialSupply, owner_, cap_);
        akapz = address(this);
    }

    // eslint-disable-next-line
    function __Akapz_Init(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address owner_,
        uint256 cap_
    ) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
        __Pausable_init_unchained();
        __ERC20Burnable_init_unchained();
        __ERC20Capped_init_unchained(cap_ * 10**18);
        _owner = owner_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
        _setupRole(UPGRADER_ROLE, _msgSender());
        _totalBurned = 0;
        _totalLocked = 0;
        mint(owner_, initialSupply * 10**18);
    }
 // eslint-disable-next-line
    function _authorizeUpgrade(address) internal view override onlyOwner {
        // eslint-disable
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20PausableUpgradeable, ERC20Upgradeable) {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have pauser role to unpause"
        );
        _unpause();
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20CappedUpgradeable, ERC20Upgradeable)
    {
        require(
            ERC20Upgradeable.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    function burn(uint256 amount) public virtual override {
        require(
            hasRole(BURNER_ROLE, _msgSender()),
            "must have burner role to burn"
        );

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual override {
        require(
            hasRole(BURNER_ROLE, _msgSender()),
            "must have burner role to burn"
        );

        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(
            hasRole(BURNER_ROLE, _msgSender()),
            "must have burner role to burn"
        );

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        _totalBurned += amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function mint(address to, uint256 amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "must have minter role to mint"
        );
        _mint(to, amount);
    }

    function _init() private {
        emit Initialized("Akapz token", msg.sender, block.timestamp); // only using block.timestamp for event purpose never use it anywhere else!
    }

    modifier onlyUninitialized() {
        require(_initializedParams != true, "already initialized");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "only owner can execute");
        _;
    }

    modifier noZeroAddress() {
        require(msg.sender != address(0), "no zero addresss");
        _;
    }


    modifier enoughFunds(uint256 amount, address wallet) {
        require(_balances[wallet] >= amount, "balance is not sufficient");
        _;
    }

    modifier dateAfterNow(uint256 target) {
        uint256 _now = block.timestamp;
        require(_now < target, "invalid target date");
        _;
    }

    function setLogoUrl(string memory logoUrl) public onlyOwner {
        _ipfsLogoUrl = logoUrl;
    }

    function logoUri() public view returns (string memory) {
        return _ipfsLogoUrl;
    }
}
