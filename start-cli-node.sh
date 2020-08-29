#!/bin/sh

leopays-node \
  --config-dir=./config/leopays_node \
  --data-dir=./data/leopays_node \
  --disable-replay-opts \
  --genesis-json ./config/leopays_node/genesis.json
