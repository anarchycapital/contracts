pragma solidity ^0.8.0;

interface IStakeable {

    function Stakeable() external view virtual returns(bool);

    function HasParent() external view virtual returns(bool);

    function _beforeStake(address memory token, address to, uint256 amount) internal virtual;

    function _afterStake(address memory token, address to, uint256 amount) internal virtual;

    function _stake(uint256 _amount) internal;

    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    event UnStaked(address indexed token, address indexed to, uint256 amount);


}