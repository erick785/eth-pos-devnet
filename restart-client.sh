set -e

docker compose down

# Clean Folders
#git clean -fxd
rm -rf client/consensus/beacondata/ client/consensus/genesis.ssz client/consensus/validatordata/ client/execution/geth/

# Initialize Genesis
docker compose -f docker-initialize-client.yml run --rm geth-genesis

# Create Account
echo account_geth_address=0xF359C69a1738F74C044b4d3c2dEd36c576A34d9f > client/execution/account_geth.txt

echo account_geth_privateKey=0x28fb2da825b6ad656a8301783032ef05052a2899a81371c46ae98965a6ecbbaf >> client/execution/account_geth.txt

# Load Account info
source client/execution/account_geth.txt
echo $account_geth_privateKey | sed s/0x//g > client/execution/account_geth_privateKey

docker compose -f docker-initialize-client.yml run --rm geth-account 

#docker compose -f docker-initialize.yml up geth-account 
#docker logs eth-pos-devnet-geth-account-1 > execution/geth_account.log
#docker rm eth-pos-devnet-geth-account-1
#account_geth_address=`cat execution/geth_account.txt | grep "Public address of the key"|sed s/'.*\: *'//g`

# Add account to .env file
sed -i /^account_geth_address/d .netEnv
echo account_geth_address=$account_geth_address >> .entEnv

source .entEnv

# Make Deposit
#wget https://github.com/ethereum/staking-deposit-cli/releases/download/v2.3.0/staking_deposit-cli-76ed782-linux-amd64.tar.gz
# tar xzf staking_deposit-cli-76ed782-linux-amd64.tar.gz
# cp staking_deposit-cli-76ed782-linux-amd64/deposit .
# rm -rf staking_deposit-cli-76ed782-linux-amd64*

# wget https://github.com/ethereum/staking-deposit-cli/releases/download/v2.3.0/staking_deposit-cli-76ed782-darwin-amd64.tar.gz

# tar xzf staking_deposit-cli-76ed782-darwin-amd64.tar.gz
# cp staking_deposit-cli-76ed782-darwin-amd64/deposit .
# rm -rf staking_deposit-cli-76ed782-darwin-amd64*

# ./deposit --language English new-mnemonic --mnemonic_language English --chain mainnet || echo Skipped Depost

yarn call

docker compose -f docker-initialize-client.yml run --rm validator-accounts-import

# issue champion exchange actor copper valve nurse thrive enter shed inject virtual cereal point faint helmet fossil corn then sting retreat case piece robust

# Run Nodes
#docker compose -f docker-run.yml up -d
docker compose --env-file .netEnv -f docker-run-client.yml up geth -d
sleep 5
docker compose --env-file .netEnv -f docker-run-client.yml up beacon-chain -d
sleep 5
docker compose --env-file .netEnv  -f docker-run-client.yml up validator -d

# Show Log Commands
echo You can watch the log file
echo "	docker logs eth-pos-devnet-geth-1 -f"
echo "	docker logs eth-pos-devnet-beacon-chain-1 -f"
echo "	docker logs eth-pos-devnet-validator-1 -f"

echo You can check the beacon-chain status
echo "	curl localhost:8080/p2p"
echo "	curl localhost:3500/eth/v1/node/syncing"