//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IStakeable.sol";

contract Staking {

    using SafeMath for uint256;

    address _baseStakingToken;
    /// @notice equivalent to 0.5% per hour
    uint256 internal rewardPerHour = 5000;
    /// @notice reward will increment by 0.05% per day staked
    uint256 internal rewardIncrementsPerDay = 500;

    /// @notice a small penalty of 0.05% (one day) will happen if withdrawn before 24h or before commitment expires
    /// @notice to help prevent bot impact on the stakes
    uint256 internal rewardPenaltyPerWithdraw = 500;

    /// @notice if user is commiting to a minimum of days to stake it will get a bonus of 0.2% per hour
    uint256 internal commitmentBonusIncentive = 2000;

    /// @notice if less than treshold = penalty if more = no penalty
    uint256 internal rewardPenaltyThresholdSeconds = 3600 * 24;

    /// @notice struct Stake to hold stake information
    struct Stake {
        address account;
        uint256 amount;
        uint256 since;
        /// a user needs to commit to a minimum of days (calculated in seconds) for his staking cannot be less than 1
        uint256 commitmentSeconds;
        /// @notice when the commitment expires
        uint256 commitmentExpiry;
        uint256 commitedOn;
        uint256 claimable;
    }

    /// @notice struct StakeHolder is stakeholder information

    struct StakeHolder {
        address account;
        Stake[] address_stakes;
    }

    /**
   * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
   * @notice
    *   This is a array where we store all Stakes that are performed on the Contract
    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
    */
    StakeHolder[] internal stakeholders;
    /**
    * @notice
    * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
    * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

    /**
   * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */

   constructor() {}


    function _addStakeholder(address staker) internal returns (uint256){
        // @notice Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // @notice Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // @notice Assign the address to the new index
        stakeholders[userIndex].account = staker;
        // @notice Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    function Stakeable() public view virtual returns(bool) {
        return true;
    }


    function _stake(uint256 _amount) internal{
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");


        // @notice Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // @notice block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // @notice See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }



        // @notice Use the index to push a new Stakes
        // @notice push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0,0,0,0));

        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    function _beforeStake(address token, address to, uint256 amount) internal virtual {

    }

    function _afterStake(address  token, address to, uint256 amount) internal virtual {

    }

    function HasParent() external view virtual returns(bool) {
        return false;
    }


    modifier onlyStaker(uint256 stakeIndex) {
        require(msg.sender == stakeholders[stakeIndex].account, "does not own this stake");
        _;
    }

    function _calculateStakeRewards(Stake memory currentStake) internal view returns(uint256) {
        return (((block.timestamp - currentStake.since) / 1 hours) * currentStake.amount) / rewardPerHour;
    }

    function _calculateCommitmentBonus(Stake memory current_stake) internal view returns(uint256) {
        return (((block.timestamp - current_stake.since) / 1 hours) * current_stake.amount) / commitmentBonusIncentive;
    }

    function commitmentNotExpired(Stake memory currentStake) internal view returns(bool) {

        if(block.timestamp <= currentStake.commitmentExpiry) return false;

        return true;
    }

    function calculateRewards(Stake memory currentStake) internal view returns(uint256) {
        if (commitmentNotExpired(currentStake) && currentStake.commitmentSeconds > 0) {
            return _calculateCommitmentBonus(currentStake);
        }

        return _calculateStakeRewards(currentStake) - _calculatePenalties(currentStake);
    }


    /// @notice calculates penalties
    /// rules are (OR) :
    /// - if user commited, commitment is not respected (not expired)
    /// - if user stakes less than 24 hours ago and withdraw
    function _calculatePenalties(Stake memory current_stake) internal view returns(uint256) {
        if (commitmentNotExpired(current_stake) && current_stake.commitmentSeconds > 0 && ((current_stake.since + (24 * 1 hours)) < block.timestamp)) {
            return (((block.timestamp - current_stake.since) / 1 hours) * current_stake.amount) / rewardPenaltyPerWithdraw;
        }
        if(!commitmentNotExpired(current_stake) && current_stake.commitmentSeconds > 0 && ((current_stake.since + (24 * 1 hours)) > block.timestamp)) {
            return 0;
        }
        if ((current_stake.since + (24 * 1 hours)) < block.timestamp) {
            return (((block.timestamp - current_stake.since) / 1 hours) * current_stake.amount) / rewardPenaltyPerWithdraw;
        }

        return 0;
    }

    /**
    * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            uint256 availableReward = calculateRewards(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    /**
    * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
    */
    function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateRewards(current_stake);
        // Remove by subtracting the money unstaked
        current_stake.amount = current_stake.amount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if(current_stake.amount == 0){
            delete stakeholders[user_index].address_stakes[index];
        }else {
            // If not empty then replace the value of it
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block.timestamp;
        }

        return amount+reward;

    }
}
