import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers"
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import 'hardhat-contract-sizer';

dotenv.config();


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  solidity: "0.6.11",
  networks: {
    env: {
      url: process.env.URL || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY.split(",") : [],
    },
  },
};

export default config;
