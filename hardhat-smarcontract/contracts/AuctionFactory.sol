// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./Auction.sol";

contract CFContractFactory {
    Auction[] public s_AuctionAddresses;

    function createAuction(
        uint256[] memory milestoneDeadlines,
        uint256 targetAmount,
        uint256[] memory milestoneFunds,
        uint256 duration,
        uint256 numberOfMilestones,
        uint256 minimumAmount,
        uint256 campaignDeadline
    ) external {
        Auction myAuction = new Auction({
        milestoneDeadlines: milestoneDeadlines,
        targetAmount: targetAmount,
        milestoneFunds: milestoneFunds,
        duration: duration,
        numberOfMilestones: numberOfMilestones,
        minimumAmount: minimumAmount,
        campaignDeadline: campaignDeadline
        });

        s_AuctionAddresses.push(myAuction);
    }

    function getTheLatestAuction() external view returns (Auction) {
        return s_AuctionAddresses[s_AuctionAddresses.length - 1];
    }
}
