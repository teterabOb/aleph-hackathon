import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployCCIPSender: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("CCIPSender", {
    from: deployer,
    args: [],
    log: true,
  });

  const ccipSender = await hre.ethers.getContract<Contract>("CCIPSender", deployer);
}

export default deployCCIPSender;

deployCCIPSender.tags = ["CCIPSender"];