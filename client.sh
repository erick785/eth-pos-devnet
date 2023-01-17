set -e

rm -rf client/consensus/beacondata/ client/consensus/genesis.ssz client/consensus/validatordata/ client/execution/geth/ client/execution/keystore/

cp server/consensus/genesis.ssz client/consensus/genesis.ssz

# Initialize Genesis
docker compose -f docker-initialize-client.yml run --rm geth-genesis
#docker compose -f docker-initialize-client.yml run --rm create-beacon-chain-genesis

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
#sed -i /^account_geth_address/d .netEnv
echo account_geth_address=$account_geth_address >> .netEnv

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

# deposit
# yarn call
# sleep 10

#docker compose -f docker-initialize-client.yml run --rm validator-wallet-create

#docker compose -f docker-initialize-client.yml run --rm validator-accounts-import

# issue champion exchange actor copper valve nurse thrive enter shed inject virtual cereal point faint helmet fossil corn then sting retreat case piece robust

# Run Nodes
#docker compose -f docker-run.yml up -d

source .netEnv

# Run geth node
echo "Stating Geth Node"
nohup geth --networkid=123456 \
    --port=30303 \
	--http \
    --http.port=8546 \
	--http.api=eth,net,web3,personal,miner \
	--http.addr=0.0.0.0 \
	--http.vhosts=* \
	--http.corsdomain=* \
	--authrpc.vhosts=* \
    --authrpc.port=8552 \
	--authrpc.addr=0.0.0.0 \
	--authrpc.jwtsecret=client/execution/jwtsecret \
	--datadir=client/execution \
	--allow-insecure-unlock \
	--unlock=$account_geth_address \
	--password=client/execution/geth_password.txt \
	--syncmode=full \
	--bootnodes=$bootgeth \
	> logs/geth-2 &
sleep 5

echo "Stating Beacon Chain Node"
nohup ./prysm.sh beacon-chain \
	--datadir=client/consensus/beacondata \
	--min-sync-peers=1 \
	--genesis-state=client/consensus/genesis.ssz \
	--bootstrap-node=$bootbeacon \
	--chain-config-file=client/consensus/config.yml \
	--config-file=client/consensus/config.yml \
	--rpc-host=0.0.0.0 \
    --rpc-port=4001 \
	--grpc-gateway-host=0.0.0.0 \
    --grpc-gateway-port=3501 \
	--monitoring-host=0.0.0.0 \
    --monitoring-port=9080 \
    --p2p-tcp-port=13001 \
    --p2p-udp-port=12001 \
	--execution-endpoint=http://localhost:8552 \
	--chain-id=32382 \
	--accept-terms-of-use \
	--jwt-secret=client/execution/jwtsecret \
	--suggested-fee-recipient=$account_geth_address \
	--peer=$peer \
	> logs/beacon-chain-2 &


echo "Stating Validator Node"
nohup ./prysm.sh validator \
	--beacon-rpc-provider=localhost:4001 \
	--datadir=consensus/validatordata \
	--accept-terms-of-use \
	--chain-config-file=consensus/config.yml \
    --interop-num-validators=32
    --interop-start-index=32
	--wallet-dir=wallet_dir \
	--wallet-password-file=wallet_dir/password.txt \
	> logs/validator-2 &

# Show Log Commands
echo You can watch the log file
echo "	docker logs eth-pos-devnet-geth-1 -f"
echo "	docker logs eth-pos-devnet-beacon-chain-1 -f"
echo "	docker logs eth-pos-devnet-validator-1 -f"

echo You can check the beacon-chain status
echo "  curl localhost:8080/healthz"
echo "	curl localhost:8080/p2p"
echo "	curl localhost:3500/eth/v1/node/syncing"