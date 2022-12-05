// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./CrowdFunding.sol";

contract CFContractFactory {
    CrowdFunding[] public s_CampaignAddresses;

    function createCampaign(
        uint256 minimumAmount,
        uint256 numberOfMilestones,
        uint256[] memory milestoneFunds,
        uint256 duration,
        uint256 targetAmount
    ) external {
        CrowdFunding myCampaign = new CrowdFunding({
            minimumAmount: minimumAmount,
            numberofmilestones: numberOfMilestones,
            milestonefunds: milestoneFunds,
            duration: duration,
            targetamount: targetAmount
        });

        s_CampaignAddresses.push(myCampaign);
    }

    function getTheLatestCampaign() external view returns (CrowdFunding) {
        return s_CampaignAddresses[s_CampaignAddresses.length - 1];
    }
}
