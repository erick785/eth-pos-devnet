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
docker compose -f docker-run.yml up geth -d
sleep 5
docker compose -f docker-run.yml up beacon-chain -d
sleep 5
docker compose -f docker-run.yml up validator -d

# Write node info
sh collectNodeInfo.sh > .netEnv
cp server/consensus/genesis.ssz client/consensus/

# Show Log Commands
echo You can watch the log file
echo "	docker logs eth-pos-devnet-geth-1 -f"
echo "	docker logs eth-pos-devnet-beacon-chain-1 -f"
echo "	docker logs eth-pos-devnet-validator-1 -f"