#!/bin/bash
set -e

WALLET=hongbai-admin
ADDRESS=mantra1uvn4qgh96lc83dzu8mpf3u93lk605ls0vg0nf2

echo Storing Code...
RES=$(mantrachaind tx wasm store artifacts/cw_to_do_list.wasm --from ${WALLET} --node https://rpc.hongbai.mantrachain.io:443 --chain-id mantra-hongbai-1 --gas-prices 0.0002uom --gas auto --gas-adjustment 2 -y --output json --broadcast-mode async -y)

echo $RES

TX_HASH=$(echo $RES | jq -r .txhash)

echo Waiting for tx to be included in a block...
sleep 7

echo Getting Code ID
CODE_ID=$(mantrachaind query tx $TX_HASH --node https://rpc.hongbai.mantrachain.io:443 -o json| jq -r '.events[] | select(.type == "store_code") | .attributes[] | select(.key == "code_id") | .value')

echo $CODE_ID 

echo Instantiating Contract...
mantrachaind tx wasm instantiate $CODE_ID '{"owner": "mantra1uvn4qgh96lc83dzu8mpf3u93lk605ls0vg0nf2"}' --from ${WALLET} --label "cw-to-do-list" --no-admin --node https://rpc.hongbai.mantrachain.io:443 --chain-id $CHAIN_ID --gas-prices 0.0002uom --gas auto --gas-adjustment 1.4 --broadcast-mode async -y


echo Waiting for tx to be included in a block...
sleep 7
echo Getting Contract Address...
CONTRACT=$(mantrachaind query wasm list-contract-by-code $CODE_ID $NODE --output json | jq -r '.contracts[-1]')
echo $CONTRACT