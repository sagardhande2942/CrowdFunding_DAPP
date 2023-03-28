// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./CrowdFunding.sol";

contract Auction {

    error Auction__amountNotEnough(uint256);
    error Auction__thisCampaignIsPastDeadline(uint256);


    struct Bid {
        address bidder;
        uint256 amountOffered;
        uint256 equityInReturn;
    }

    Bid newBid;
    CrowdFunding[] public s_CampaignAddresses;
    Bid[] public bids;
    uint256 i_minimumAmount;
    uint256[] s_milestoneDeadlines;
    mapping(address => Bid) userBidMapping;
    uint256[] bidAmounts;
    uint256[] public s_milestoneFunds;
    uint256[] equities;
    int256[] negEquities; 
    uint256 public immutable i_campaignDeadline;
    uint256[] public answer;
    uint256 public immutable i_duration;
    address public auctionAddress = address(this);
    uint256 public i_numberOfMilestones;
    uint256 public immutable i_targetAmount;
    mapping(int256 => mapping(int256 => int256)) public dp;
    address public immutable i_fundsToReleaseIn = address(this);

    constructor( 
        uint256[] memory milestoneDeadlines,
        uint256 targetAmount,
        uint256[] memory milestoneFunds,
        uint256 duration,
        uint256 numberOfMilestones,
        uint256 minimumAmount,
        uint256 campaignDeadline
    ) { 
        s_milestoneDeadlines = milestoneDeadlines;
        i_targetAmount = targetAmount;
        s_milestoneFunds = milestoneFunds;
        i_duration = duration;
        i_numberOfMilestones = numberOfMilestones;
        i_minimumAmount = minimumAmount;
        i_campaignDeadline = campaignDeadline;
    }

    function getBalance(address userAddress) public view returns (uint256) {
        return address(userAddress).balance;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function saveBid(uint256 equityInReturn) public payable {
        if(differenceBetweenBlocks(i_campaignDeadline) < 0) {
            revert Auction__thisCampaignIsPastDeadline(i_campaignDeadline);
        }
        uint256 givenAmount = msg.value;
        if(givenAmount < i_minimumAmount) {
            revert Auction__amountNotEnough(givenAmount);
        }
        if(getBalance(msg.sender) > givenAmount) {
            newBid = Bid(msg.sender, givenAmount, equityInReturn);
            userBidMapping[msg.sender] = newBid;
            bids.push(newBid);
            bidAmounts.push(givenAmount);
            equities.push(equityInReturn);
            negEquities.push(-1*int256(equityInReturn));
        }
        
    }

    function differenceBetweenBlocks(uint256 timestamp) public view returns (uint256) {
        return block.timestamp - timestamp;
    }

    // TODO: output displayed in console but not getting returned
    // TODO: get maxEquityToDilute from Contract
    // TODO: returnExcessMoney not working 
    function runAuction() external  { 
            // uint256 target = i_targetAmount;
            uint256 numberOfItems = bids.length;
            
            // answer = this.knapsack(numberOfItems, target, bidAmounts, negEquities);
            for(uint256 i = 0; i < numberOfItems; i++) {
                answer.push(0);
            }
            for(uint256 i = 0; i < 3; i++) {
                answer[i] = 1;
            }
            for(uint256 i = 0;i < numberOfItems;i++){
                if(answer[i] == 0) {
                    returnExcessMoney(payable(bids[i].bidder), bids[i].amountOffered);
                }
            }
    }

    // function knapsack(
    //     uint256 numberOfItems,
    //     uint256 totalWeight,
    //     uint256[] memory weights,
    //     int256[] memory values
    // ) public returns(uint256[] memory) {
    //     int256 i;
    //     int256 j;
    //     for (i = 0; i < int256(numberOfItems); i++) {
    //         for (j = 0; j <= int256(totalWeight); j++) {
    //             if (i == 0) {
    //                 if (j >= int256(weights[0])) {
    //                     dp[i][j] = values[0];
    //                     continue;
    //                 }
    //                 dp[i][j] = 0;
    //                 continue;
    //             }
    //             if (j < int256(weights[uint256(i)])) {
    //                 dp[i][j] = dp[i - 1][j] + 0;
    //                 continue;
    //             }

    //             int256 a = dp[i - 1][j - int256(weights[uint256(i)])] + values[uint256(i)];
    //             int256 b = dp[i - 1][j];

    //             dp[i][j] = a >= b ? a : b;
    //         }
    //     }

    //     uint256[] memory bidsAccepted = new uint256[](numberOfItems);
    //     i = int256(numberOfItems) - 1;
    //     j = int256(totalWeight);
    //     while (i > 0 && j > 0) {
    //         if (dp[i][j] == dp[i - 1][j]) {
    //             i--;
    //             bidsAccepted[uint256(i)] = 0;
    //         }
    //         else {
    //             bidsAccepted[uint256(i)] = 1;
    //             i--;
    //             j -= int256(weights[uint256(i)]);
    //         }
    //     }

    //     return bidsAccepted;
    //     // return dp[numberOfItems - 1][totalWeight];
    // }

    function returnExcessMoney(address payable userAddress, uint256 amount) public {
        if(getContractBalance() > amount){
            userAddress.transfer(amount);
        }
    }

    function createCampaign() external { 
        CrowdFunding myCampaign = new CrowdFunding({ 
            numberofmilestones: i_numberOfMilestones,
            milestonefunds: s_milestoneFunds,
            duration: i_duration,
            targetamount: i_targetAmount,
            milestoneDeadlines: s_milestoneDeadlines,
            auctionAdress: auctionAddress,
            fundsToReleaseIn: i_fundsToReleaseIn
            
        });
        payable(address(myCampaign)).transfer(getBalance(address(this)));

        s_CampaignAddresses.push(myCampaign);
    }

    // TODO
    // function sendAuctionWinners() external {} 
    // No need for this, can always check the winners array (public) maybe.

}