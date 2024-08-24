import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployReceiverCChain: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("ReceiverCChain", {
    from: deployer,
    args: [],
    log: true,
  });

  const receiverCChain = await hre.ethers.getContract<Contract>("ReceiverCChain", deployer);
}

export default deployReceiverCChain;

deployReceiverCChain.tags = ["ReceiverCChain"];