require("@nomicfoundation/hardhat-toolbox")
require("hardhat-deploy")
require("solidity-coverage")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.17",
    defaultNetwork: "hardhat",
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
}
