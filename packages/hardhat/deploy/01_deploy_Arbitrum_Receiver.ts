import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";  

const deployArbitrumReceiver: DeployFunction = async function (hre: HardhatRuntimeEnvironment) { 
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    
    const { deployer } = await getNamedAccounts();
    
    await deploy("ArbitrumReceiver", {
        from: deployer,
        args: [],
        log: true,
        //gasLimit: 4000000,
    });
    
    const arbitrumReceiver = await hre.ethers.getContract<Contract>("ArbitrumReceiver", deployer);
}

export default deployArbitrumReceiver;

deployArbitrumReceiver.tags = ["ArbitrumReceiver"];