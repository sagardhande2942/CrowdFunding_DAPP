const { ethers } = require("ethers")

module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const crowdFundingArgs = [
        ethers.utils.parseEther('50'),
        4,
        [200, 200, 300, 300],
        120,
        1000, 
    ]

    const crowdFunding = await deploy("CrowdFunding", {
        from: deployer,
        args: crowdFundingArgs, 
        log: true,
    })
}

module.exports.tags = ["normal", "all"]
