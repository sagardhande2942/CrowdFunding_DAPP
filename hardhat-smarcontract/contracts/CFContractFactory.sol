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
    ) public external returns(CrowdFunding){
        CrowdFunding myCampaign = new CrowdFunding({
            minimumAmount: minimumamount,
            numberofmilestones: numberofmilestones,
            milestoneFunds: milestoneFunds,
            duration: duration,
            targetAmount: targetAmount
        });

        s_CampaignAddresses.push(myCampaign);
        return myCampaign;
    }
}
