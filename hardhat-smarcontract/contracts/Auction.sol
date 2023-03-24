// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./CrowdFunding.sol";

contract Auction {
    struct Bid {
        address bidder;
        uint256 amountOffered;
        uint256 equityInReturn;
    }

    Bid newBid;
    CrowdFunding[] public s_CampaignAddresses;
    Bid[] public bids;
    uint256[] s_milestoneDeadlines;
    mapping(address => Bid) userBidMapping;
    uint256[] bidAmounts;
    uint256[] public s_milestoneFunds;
    uint256[] equities;
    uint256[] public answer;
    uint256 public immutable i_duration;
    address public auctionAddress = address(this);
    uint256 public i_numberOfMilestones;
    uint256 public immutable i_targetAmount;
    mapping(uint256 => mapping(uint256 => uint256)) public dp;

    constructor( 
        uint256[] memory milestoneDeadlines,
        uint256 targetAmount,
        uint256[] memory milestoneFunds,
        uint256 duration,
        uint256 numberOfMilestones
    ) { 
        s_milestoneDeadlines = milestoneDeadlines;
        i_targetAmount = targetAmount;
        s_milestoneFunds = milestoneFunds;
        i_duration = duration;
        i_numberOfMilestones = numberOfMilestones;
    }

    function getBalance(address userAddress) public view returns (uint256) {
        return address(userAddress).balance;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function receiveAmount() public payable {}


    // TODO: need to test properly, there is something wrong related to money
    function saveBid(uint256 equityInReturn) public payable {
        uint256 givenAmount = msg.value;
        if(getBalance(msg.sender) > givenAmount){
            receiveAmount();
            newBid = Bid(msg.sender, givenAmount, equityInReturn);
            userBidMapping[msg.sender] = newBid;
            bids.push(newBid);
            bidAmounts.push(givenAmount);
            equities.push(equityInReturn);
        }
        
    }

    // TODO: output displayed in console but not getting returned
    // TODO: get maxEquityToDilute from Contract
    // TODO: returnExcessMoney not working 
    function runAuction(bool shouldRun) external  {
        if(shouldRun == true){
            uint256 maxEquityToDilute = 60;
            uint256 numberOfItems = bids.length;
            answer = this.knapsack(numberOfItems, maxEquityToDilute, equities, bidAmounts);
            for(uint256 i = 0;i < numberOfItems;i++){
                if(answer[i] == 0){
                    returnExcessMoney(payable(bids[i].bidder), bids[i].amountOffered);
                }
            } 
        }
    }

    function knapsack(
        uint256 numberOfItems,
        uint256 totalWeight,
        uint256[] memory weights,
        uint256[] memory values
    ) public returns(uint256[] memory) {
        uint256 i;
        uint256 j;
        for (i = 0; i < numberOfItems; i++) {
            for (j = 0; j <= totalWeight; j++) {
                if (i == 0) {
                    if (j >= weights[0]) {
                        dp[i][j] = values[0];
                        continue;
                    }
                    dp[i][j] = 0;
                    continue;
                }
                if (j < weights[i]) {
                    dp[i][j] = dp[i - 1][j] + 0;
                    continue;
                }

                uint256 a = dp[i - 1][j - weights[i]] + values[i];
                uint256 b = dp[i - 1][j];

                dp[i][j] = a >= b ? a : b;
            }
        }

        uint256[] memory bidsAccepted = new uint256[](numberOfItems);
        i = numberOfItems - 1;
        j = totalWeight;
        while (i > 0 && j > 0) {
            if (dp[i][j] == dp[i - 1][j]) {
                i--;
                bidsAccepted[i] = 0;
            }
            else {
                bidsAccepted[i] = 1;
                i--;
                j -= weights[i];
            }
        }

        return bidsAccepted;
        // return dp[numberOfItems - 1][totalWeight];
    }

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
            auctionAdress: auctionAddress
        });

        s_CampaignAddresses.push(myCampaign);
    }

    // TODO
    // function sendAuctionWinners() external {} 
    // No need for this, can always check the winners array (public) maybe.

}