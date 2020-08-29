#!/bin/sh

mkdir -p ./data/leopays_wallet/data

leopays-wallet \
  --config-dir=config/leopays_wallet \
  --data-dir=data/leopays_wallet/data
