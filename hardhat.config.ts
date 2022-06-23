import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-erc1820";
import "hardhat-deploy";
import "hardhat-deploy-ethers";

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.13",
  networks: {
    hardhat: {
      blockGasLimit: 20_000_000,
      initialBaseFeePerGas: 1,
      gasPrice: 3,
      chainId: 9001,
      allowUnlimitedContractSize: true,
      saveDeployments: true,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  namedAccounts: {
    deployer: 0,
    tokenOwner: 1,
    exploiter: 2,
  },
};

export default config;
