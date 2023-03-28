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
    error CrowdFunding__deadlineIsNotReachedForThisMilestone(uint256);
    error CrowdFunding__fundGeneratedGreaterThanTargetAmount(uint256);
    error CrowdFunding__thisFunderHasntFundedTheCampagin(address);

    struct Bid {
        address bidder;
        uint256 amountOffered;
        uint256 equityInReturn;
    }

    // uint256 public immutable i_MinimumAmount;
    // address[] public s_Funders;
    uint256[] public s_milestoneFunds;
    uint256[] public s_milestoneDeadlines;
    // mapping(address => bool) s_FundersMap;
    // mapping(address => uint256) s_FundersFund;
    uint256 public s_lastBlockTimeStamp;
    uint256 public immutable i_Duration;
    uint256 public s_NumberOfMilestones = 4;
    uint256 public s_CurrentMilestone = 0;
    address public immutable i_owner;
    uint256 public immutable i_TargetAmount;
    address public immutable i_auctionAdress;
    address public immutable i_campaignAddress = address(this);
    address[] public s_campaignFundersAddress;
    uint256[] public s_campaignFundersFunds;
    address public immutable i_fundsToRelaseIn;
    uint256 votersAgg = 0;

    constructor(
        // uint256 minimumAmount,
        uint256 numberofmilestones,
        uint256[] memory milestonefunds,
        uint256 duration,
        uint256 targetamount,
        uint256[] memory milestoneDeadlines,
        address auctionAdress,
        address fundsToReleaseIn
    ) {
        // i_MinimumAmount = minimumAmount;
        s_milestoneFunds = milestonefunds;
        s_lastBlockTimeStamp = block.timestamp;
        i_Duration = duration;
        s_CurrentMilestone = 0;
        s_NumberOfMilestones = numberofmilestones;
        i_owner = msg.sender;
        i_TargetAmount = targetamount;
        s_milestoneDeadlines = milestoneDeadlines;
        i_auctionAdress = auctionAdress;
        i_fundsToRelaseIn = fundsToReleaseIn;
    }

    bool[] s_milestoneStatus = new bool[](s_NumberOfMilestones);

    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     revert CrowdFunding__youHaveReachedFallback(msg.sender, msg.value);
    // }

    // function fund() public payable {
    //     if (isDeadlinePassed() == true) {
    //         revert CrowdFunding__thisCampaignIsPastDeadline();
    //     }

    //     if (msg.value < i_MinimumAmount) {
    //         revert CrowdFunding__amountNotEnough();
    //     }

    //     if (getBalance() > i_TargetAmount) {
    //         payable(msg.sender).transfer(msg.value);
    //         revert CrowdFunding__fundGeneratedGreaterThanTargetAmount(
    //             i_TargetAmount - getBalance()
    //         );
    //     }

    //     if (s_FundersMap[msg.sender] == true) {
    //         s_FundersFund[msg.sender] += msg.value;
    //     } else {
    //         s_Funders.push(msg.sender);
    //         s_FundersMap[msg.sender] = true;
    //         s_FundersFund[msg.sender] = msg.value;
    //     }
    // }

    function fundRelease() public payable {
        if (s_CurrentMilestone >= s_NumberOfMilestones) {
            revert CrowdFunding__allMileStonesReached(s_NumberOfMilestones);
        }

        uint256 fundToBeReleased = s_milestoneFunds[s_CurrentMilestone-1];

        if (fundToBeReleased > getBalance()) {
            revert CrowdFunding__notEnoughFundsToReleaseForThisMilestone(getBalance());
        }

        payable(i_fundsToRelaseIn).transfer(fundToBeReleased);
    }

    // function getFundsByAddress(address funder) external view returns (uint256) {
    //     if (s_FundersMap[funder] == false) {
    //         revert CrowdFunding__thisFunderHasntFundedTheCampagin(funder);
    //     }
    //     return s_FundersFund[funder];
    // }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function milestonePassed() internal {
        if(differenceBetweenBlocks(s_milestoneDeadlines[s_CurrentMilestone]) >= 0) {
            s_CurrentMilestone += 1;
            fundRelease();
        } else {
            revert CrowdFunding__deadlineIsNotReachedForThisMilestone(s_milestoneDeadlines[s_CurrentMilestone]);
        }
    }

    function milestoneReachCheck() view public returns(bool) {
        if(differenceBetweenBlocks(s_milestoneDeadlines[s_CurrentMilestone]) < 0) {
            return false;
        }
        return true;
    }

    function voteForMilestone(uint256 vote) external  {
        if(milestoneReachCheck() == false) {
            if(s_CurrentMilestone + 1 >= s_milestoneFunds.length) {
                revert CrowdFunding__allMileStonesReached(s_CurrentMilestone+1);
            }
            revert CrowdFunding__deadlineIsNotReachedForThisMilestone(s_milestoneDeadlines[s_CurrentMilestone]);
        }
        votersAgg += vote;
    }

    function endVotingSession() external {
        if(votersAgg > 0 && milestoneReachCheck() == true) {
            milestonePassed();
            votersAgg = 0;
        }
        else {
            require(false, "Conditions not met!!");
        }
    }

    // function getNumberOfFunders() public view returns (uint256) {
    //     return s_Funders.length;
    // }

    function isDeadlinePassed() public view returns (bool) {
        return (block.timestamp - s_lastBlockTimeStamp) > i_Duration;
    }

    function differenceBetweenBlocks(uint256 timestamp) public view returns (uint256) {
        return block.timestamp - timestamp;
    }

    // function getMinimumAmount() public view returns (uint256) {
    //     return i_MinimumAmount;
    // }

    function getMilestoneAmount(uint256 index) public view returns (uint256) {
        return s_milestoneFunds[index];
    }

    function getNumberOfMilestones() public view returns (uint256) {
        return s_NumberOfMilestones;
    }

    function getDuration() public view returns (uint256) {
        return i_Duration;
    }

    function getTargetAmount() public view returns (uint256) {
        return i_TargetAmount;
    }

    function getCurrentMilestone() public view returns (uint256) {
        return s_CurrentMilestone;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        _;
    }
}
