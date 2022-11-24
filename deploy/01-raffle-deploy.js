const ENTRANCE_FEE = ethers.utils.parseEther("0.1");


module.exports = async({ getNamedAccounts, deployments }) => {
    const{ deploy, log } = deployments;
    const { deployer } = await getNamedAccounts()

    const args = [ENTRANCE_FEE, 
                    "300", 
                    "0x2ca8e0c643bde4c2e08ab1fa0da3401adad7734d",
                    "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
                    "6853",
                    "500000"
                    ]

    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
    })
}