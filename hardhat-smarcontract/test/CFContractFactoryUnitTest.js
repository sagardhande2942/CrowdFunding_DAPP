const { ethers } = require("hardhat")
const { assert, expect } = require("chai")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")

describe("Crowdfunding Campaign Factory Test", () => {
    let cfContract, cfContractFactory

    var campaignArgs = [
        [
            ethers.utils.parseEther("50"),
            4,
            [
                ethers.utils.parseEther("200"),
                ethers.utils.parseEther("200"),
                ethers.utils.parseEther("300"),
                ethers.utils.parseEther("300"),
            ],
            2,
            ethers.utils.parseEther("1000"),
        ],
        [
            ethers.utils.parseEther("30"),
            2,
            [ethers.utils.parseEther("500"), ethers.utils.parseEther("500")],
            1,
            ethers.utils.parseEther("1000"),
        ],
        [
            ethers.utils.parseEther("20"),
            5,
            [
                ethers.utils.parseEther("200"),
                ethers.utils.parseEther("200"),
                ethers.utils.parseEther("300"),
                ethers.utils.parseEther("300"),
                ethers.utils.parseEther("500"),
            ],
            2,
            ethers.utils.parseEther("1500"),
        ],
    ]

    beforeEach(async () => {
        cfContractFactory = await ethers.getContractFactory("CFContractFactory")
        cfContract = await cfContractFactory.deploy()
    })

    it("Check if multiple crowdfunding contracts are being generated", async () => {
        for (let i = 0; i < 2; i++) {
            await cfContract.createCampaign(...campaignArgs[i])
            const crowdFundingAddress = await cfContract.getTheLatestCampaign()
            const crowFunding = await ethers.getContractAt("CrowdFunding", crowdFundingAddress)
            const minimumAmount = await crowFunding.getMinimumAmount()
            assert.equal(
                parseFloat(ethers.utils.formatEther(minimumAmount)),
                parseFloat(ethers.utils.formatEther(campaignArgs[i][0]))
            )
        }
    })

    it("Check if all addresses are available!!", async () => {
        let myAddressArray = []
        for (let i = 0; i < 2; i++) {
            await cfContract.createCampaign(...campaignArgs[i])
            const crowdFundingAddress = await cfContract.getTheLatestCampaign()
            myAddressArray.push(crowdFundingAddress)
        }

        // console.log(myAddressArray)
        for (let i = 0; i < 2; i++) {
            assert.equal(myAddressArray[i].length, 42)
        }
    })
})
