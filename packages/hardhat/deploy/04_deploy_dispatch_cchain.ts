import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployDispatchCChain: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("DispatchCChain", {
    from: deployer,
    args: [],
    log: true,
  });

  const dispatchCChain = await hre.ethers.getContract<Contract>("DispatchCChain", deployer);
}

export default deployDispatchCChain;

deployDispatchCChain.tags = ["DispatchCChain"];