const { ethers } = require("hardhat")
const { assert, expect } = require("chai")

describe("CrowdFundingTest", () => {
    let crowdFunding, crowdFundingFactory
    var crowdFundingArgs = [
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
    ]
    beforeEach(async () => {
        crowdFundingFactory = await ethers.getContractFactory("CrowdFunding")
        crowdFunding = await crowdFundingFactory.deploy(
            crowdFundingArgs[0],
            crowdFundingArgs[1],
            crowdFundingArgs[2],
            crowdFundingArgs[3],
            crowdFundingArgs[4]
        )
    })

    it("Check if all details from constructor are present!!", async () => {
        const minimumAmount = await crowdFunding.getMinimumAmount()
        assert.equal(minimumAmount.toString(), crowdFundingArgs[0])

        const numberOfMilestones = await crowdFunding.getNumberOfMilestones()
        assert.equal(numberOfMilestones.toString(), crowdFundingArgs[1])

        for (let i = 0; i < 3; i++) {
            let mileStoneValue = await crowdFunding.getMilestoneAmount(i.toString())
            assert.equal(crowdFundingArgs[2][i], mileStoneValue.toString())
        }

        const duration = await crowdFunding.getDuration()
        assert.equal(duration.toString(), crowdFundingArgs[3])

        const targetAmount = await crowdFunding.getTargetAmount()
        assert.equal(targetAmount.toString(), crowdFundingArgs[4])
    })

    it("Check if Fund function is working!!", async () => {
        const amountToFund = "60"
        const initialBalance = (await crowdFunding.getBalance()).toString()
        await crowdFunding.fund({ value: ethers.utils.parseEther(amountToFund) })
        const finalBalance = (await crowdFunding.getBalance()).toString()

        assert.equal(
            parseFloat(ethers.utils.formatEther(initialBalance)) + parseFloat(amountToFund),
            parseFloat(ethers.utils.formatEther(finalBalance))
        )
    })

    it("Check if Fund transferred are not enough", async () => {
        const amountToFund = "30"
        try {
            await crowdFunding.fund({ value: ethers.utils.parseEther(amountToFund) })
        } catch (e) {
            return
        }
        throw "Error"
    })

    it("Check if Fund amount greater than target reverting or not", async () => {
        const amountToFund = "1002"
        try {
            await crowdFunding.fund({ value: ethers.utils.parseEther(amountToFund) })
        } catch (e) {
            return
        }
        throw "Error"
    })

    it("Check if Fund from different accounts are registering!!", async () => {
        const amountToFund = ["70", "100"]
        const [owner, addr1, addr2] = await ethers.getSigners()
        const initialBalance = await crowdFunding.getBalance()
        await crowdFunding.connect(addr1).fund({ value: ethers.utils.parseEther(amountToFund[0]) })
        const initialFunders = await crowdFunding.getNumberOfFunders()
        await crowdFunding.connect(addr2).fund({ value: ethers.utils.parseEther(amountToFund[1]) })
        const finalFunders = await crowdFunding.getNumberOfFunders()
        const finalBalance = await crowdFunding.getBalance()

        const fundsOfAddr1 = await crowdFunding.getFundsByAddress(addr1.address)
        const fundsOfAddr2 = await crowdFunding.getFundsByAddress(addr2.address)

        assert.equal(
            parseFloat(amountToFund[0]),
            parseFloat(ethers.utils.formatEther(fundsOfAddr1))
        )

        assert.equal(
            parseFloat(amountToFund[1]),
            parseFloat(ethers.utils.formatEther(fundsOfAddr2))
        )

        assert.equal(parseInt(initialFunders) + 1, parseInt(finalFunders))
        assert.equal(
            parseFloat(ethers.utils.formatEther(initialBalance)) +
                parseFloat(amountToFund[0]) +
                parseFloat(amountToFund[1]),
            parseFloat(ethers.utils.formatEther(finalBalance))
        )
    })

    it("Check if deadline is passed!!", async () => {
        await new Promise((r) => setTimeout(r, 3000))
        try {
            await crowdFunding.fund({ value: ethers.utils.parseEther("100") })
        } catch (error) {}
        let deadlinePassed = await crowdFunding.isDeadlinePassed()
        assert.equal(deadlinePassed, true)
    })

    it("Check if funding stops after the deadline!!", async () => {
        await new Promise((r) => setTimeout(r, 3000))
        try {
            await crowdFunding.fund({ value: ethers.utils.parseEther("100") })
        } catch (e) {
            return
        }
        throw "Error"
    })

    it("Check if release of Milestone Funds is working properly!!", async () => {
        await crowdFunding.fund({ value: ethers.utils.parseEther("1000") })
        let currentMilestone = parseInt(await crowdFunding.getCurrentMilestone())
        const [owner] = await ethers.getSigners()

        // Release funds for milestones
        for (let i = currentMilestone; i < crowdFundingArgs[1]; i++) {
            const initialWalletBalance = ethers.utils.formatEther(await crowdFunding.getBalance())
            const initialOwnerBalance = ethers.utils.formatEther(
                await ethers.provider.getBalance(owner.address)
            )

            await crowdFunding.fundRelease()

            const finalWalletBalance = ethers.utils.formatEther(await crowdFunding.getBalance())
            const finalOwnerBalance = ethers.utils.formatEther(
                await ethers.provider.getBalance(owner.address)
            )
            const milestoneFund = ethers.utils.formatEther(crowdFundingArgs[2][i])

            assert.equal(initialWalletBalance - milestoneFund, finalWalletBalance)
            assert.approximately(
                parseFloat(initialOwnerBalance) + parseFloat(milestoneFund),
                parseFloat(finalOwnerBalance),
                1
            )
        }
        let finalWalletBalance = ethers.utils.formatEther(await crowdFunding.getBalance())
        assert.equal(finalWalletBalance, 0)

        try {
            await crowdFunding.fundRelease()
        } catch (e) {
            return
        }

        throw "Error, fund shouldnt be released"
    })
})
