import { ethers } from "hardhat";
import * as fs from "fs";


async function main() {

  const [call] = await ethers.getSigners();

  console.log("Call address:", call.address);

  console.log("Call balance:", (await call.getBalance()).toString());



  const DepositContract = (await ethers.getContractFactory("DepositContract")).attach("0x4242424242424242424242424242424242424242");

  console.log("DepositContract address:", DepositContract.address);

  console.log("root", await DepositContract.get_deposit_root());

  console.log("count", await DepositContract.get_deposit_count());

  console.log("DepositContract balance:", (await ethers.provider.getBalance(DepositContract.address)).toString());


  // 读取文件中的数据
  const data = fs.readFileSync('./validator_keys/deposit_data-1672649140.json', 'utf-8');

  // 将数据转换为json对象 
  const validator = JSON.parse(data);

  // call deposit
  const depositData = {
    pubkey: "0x" + validator[0].pubkey,
    withdrawal_credentials: "0x" + validator[0].withdrawal_credentials,
    signature: "0x" + validator[0].signature,
    deposit_data_root: "0x" + validator[0].deposit_data_root,
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
