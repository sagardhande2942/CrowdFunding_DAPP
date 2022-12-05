module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const crowdFunding = await deploy("CFContractFactory", {
        from: deployer,
        args: [],
        log: true,
    })
}

module.exports.tags = ['factory', 'all']
