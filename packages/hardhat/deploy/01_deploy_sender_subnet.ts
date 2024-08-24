import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import {Contract} from "ethers";

const deploySenderSubnet: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("SenderSubnet", {
    from: deployer,
    args: [],
    log: true,
  });

  const senderSubnet = await hre.ethers.getContract<Contract>("SenderSubnet", deployer);
};

export default deploySenderSubnet;

deploySenderSubnet.tags = ["SenderSubnet"];