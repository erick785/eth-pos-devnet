set -e 

docker compose down

# Clean Folders
#git clean -fxd
rm -rf server/consensus/beacondata/ server/consensus/genesis.ssz server/consensus/validatordata/ server/execution/geth/

# Initialize Genesis
#docker compose -f docker-initialize.yml up && docker compose -f docker-initialize.yml down
docker compose -f docker-initialize.yml run --rm geth-genesis
docker compose -f docker-initialize.yml run --rm create-beacon-chain-genesis

# Run Nodes
#docker compose -f docker-run.yml up -d
echo "Stating Geth Node"
nohup geth --networkid=123456 \
	--http \
	--http.api=eth,net,web3,personal,miner \
	--http.addr=0.0.0.0 \
	--http.vhosts=* \
	--http.corsdomain=* \
	--authrpc.vhosts=* \
	--authrpc.addr=0.0.0.0 \
	--authrpc.jwtsecret=server/execution/jwtsecret \
	--datadir=server/execution \
	--allow-insecure-unlock \
	--unlock=0x123463a4b065722e99115d6c222f267d9cabb524 \
	--password=server/execution/geth_password.txt \
	--syncmode=full \
    --mine \
	> logs/geth-1 2>&1 &
sleep 5

echo "Stating Beacon Chain Node"
nohup ./prysm.sh beacon-chain \
	--datadir=server/consensus/beacondata \
	--min-sync-peers=0 \
	--interop-genesis-state=server/consensus/genesis.ssz \
    --interop-eth1data-votes \
    --contract-deployment-block=0 \
	--chain-config-file=server/consensus/config.yml \
	--config-file=server/consensus/config.yml \
	--rpc-host=0.0.0.0 \
	--grpc-gateway-host=0.0.0.0 \
	--monitoring-host=0.0.0.0 \
	--execution-endpoint=http://localhost:8551 \
	--chain-id=32382 \
	--accept-terms-of-use \
	--jwt-secret=server/execution/jwtsecret \
	--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
	> logs/beacon-chain-1 2>&1 &

echo "Stating Validator Node"
nohup ./prysm.sh validator \
	--beacon-rpc-provider=localhost:4000 \
	--datadir=server/consensus/validatordata \
	--accept-terms-of-use \
	--chain-config-file=server/consensus/config.yml \
    --interop-num-validators=32 \
    --interop-start-index=0 \
	> logs/validator-1 2>&1 &

# Write node info
sh collectNodeInfo.sh > .netEnv
cp server/consensus/genesis.ssz client/consensus/

# Show Log Commands
echo You can watch the log file
echo "clear && tail -f ./logs/geth-1 -n1000"
echo "clear && tail -f ./logs/beacon-chain-1 -n1000"
echo "clear && tail -f .//logs/validator-1 -n1000"

