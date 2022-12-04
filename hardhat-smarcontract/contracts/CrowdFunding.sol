//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract CrowdFunding {
    /*
        1. fund (also called by the receive function)
        2. withdraw
        3. 
    */

    error CrowdFunding__amountNotEnough();
    error CrowdFunding__youHaveReachedFallback(address, uint256);
    error CrowdFunding__thisCampaignIsPastDeadline();
    error CrowdFunding__allMileStonesReached(uint256);
    error CrowdFunding__notEnoughFundsToReleaseForThisMilestone(uint256);
    error CrowdFunding__fundGeneratedGreaterThanTargetAmount(uint256);

    uint256 public immutable i_MinimumAmount;
    address[] public s_Funders;
    uint256[] public s_MilestoneFunds;
    mapping(address => bool) s_FundersMap;
    mapping(address => uint256) s_FundersFund;
    uint256 public s_lastBlockTimeStamp;
    uint256 public immutable i_Duration;
    uint256 public immutable i_NumberOfMilestones;
    uint256 public s_CurrentMilestone;
    address public immutable i_owner;
    uint256 public immutable i_TargetAmount;

    constructor(
        uint256 minimumAmount,
        uint256 numberofmilestones,
        uint256[] memory milestonefunds,
        uint256 duration,
        uint256 targetamount
    ) {
        i_MinimumAmount = minimumAmount;
        s_MilestoneFunds = milestonefunds;
        s_lastBlockTimeStamp = block.timestamp;
        i_Duration = duration;
        s_CurrentMilestone = 0;
        i_NumberOfMilestones = numberofmilestones;
        i_owner = msg.sender;
        i_TargetAmount = targetamount;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        revert CrowdFunding__youHaveReachedFallback(msg.sender, msg.value);
    }

    function fund() public payable {
        if (isDeadlinePassed() == true) {
            revert CrowdFunding__thisCampaignIsPastDeadline();
        }

        if (msg.value < i_MinimumAmount) {
            revert CrowdFunding__amountNotEnough();
        }

        if (getBalance() + msg.value > i_TargetAmount) {
            revert CrowdFunding__fundGeneratedGreaterThanTargetAmount(
                i_TargetAmount - getBalance()
            );
        }

        if (s_FundersMap[msg.sender] == true) {
            s_FundersFund[msg.sender] += msg.value;
        } else {
            s_Funders.push(msg.sender);
            s_FundersMap[msg.sender] = true;
            s_FundersFund[msg.sender] = msg.value;
        }
    }

    function fundRelease() external payable onlyOwner {
        if (s_CurrentMilestone >= i_NumberOfMilestones) {
            revert CrowdFunding__allMileStonesReached(i_NumberOfMilestones);
        }

        uint256 fundToBeReleased = s_MilestoneFunds[s_CurrentMilestone];

        if (fundToBeReleased > getBalance()) {
            revert CrowdFunding__notEnoughFundsToReleaseForThisMilestone(getBalance());
        }

        payable(msg.sender).transfer(fundToBeReleased);

        s_CurrentMilestone += 1;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getNumberOfFunders() public view returns (uint256) {
        return s_Funders.length();
    }

    function isDeadlinePassed() public view returns (bool) {
        return (block.timestamp - s_lastBlockTimeStamp) > i_Duration;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        _;
    }
}
