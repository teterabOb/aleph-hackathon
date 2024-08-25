import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployDispatchEcho: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("DispatchEcho", {
    from: deployer,
    log: true,
  });
};

export default deployDispatchEcho;

deployDispatchEcho.tags = ["DispatchEcho"];