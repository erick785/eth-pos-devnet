import { ethers } from "hardhat";
import * as fs from "fs";


async function main() {

  const [call, newValidator] = await ethers.getSigners();

  console.log("Call address:", call.address);
  console.log("New validator address:", newValidator.address);

  // call transfer to new validator 33 eth
  await (await call.sendTransaction({
    to: newValidator.address,
    value: ethers.utils.parseEther("33"), // Sends exactly 1.0 ether
  })).wait();

  console.log("Call balance:", (await call.getBalance()).toString());
  console.log("Call balance:", (await newValidator.getBalance()).toString());


  const DepositContract = (await ethers.getContractFactory("DepositContract")).attach("0x4242424242424242424242424242424242424242");

  // 读取文件中的数据
  const data = fs.readFileSync('./scripts/validator.json', 'utf-8');

  // 将数据转换为json对象 
  const validator = JSON.parse(data);

  // call deposit
  const depositData = {
    pubkey: validator.pubkey,
    withdrawal_credentials: validator.withdrawal_credentials,
    signature: validator.signature,
    deposit_data_root: validator.deposit_data_root,
  };

  console.log("depositData:", depositData);

  await (await DepositContract.deposit(depositData.pubkey, depositData.withdrawal_credentials, depositData.signature, depositData.deposit_data_root, { value: ethers.utils.parseEther("32") })).wait();

  console.log("Call balance:", (await call.getBalance()).toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
