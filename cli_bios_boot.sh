#!/bin/bash

# set up a wallet just for holding the key used during blockchain ignition

###INSERT envars
. ./.environment-cli

logfile=$wddir/bootlog.txt

if [ -e $wddir ]; then
    rm -rf $wddir
fi
mkdir $wddir

step=1
echo Initializing ignition sequence  at $(date) | tee $logfile
echo "FEATURE_DIGESTS: $FEATURE_DIGESTS" >> $logfile
echo "http-server-address = $wdaddr" > $wddir/config.ini

sleep 1
ecmd get info

wcmd create --to-console -n ignition

### INSERT lpc leopays init key
wcmd import -n ignition --private-key $LPC_LEOPAYS_INIT_PRIV_KEY
### INSERT lpc new keys
wcmd import -n ignition --private-key $LPC_OWNER_PRIV_KEY
wcmd import -n ignition --private-key $LPC_ACTIVE_PRIV_KEY
### INSERT leopays new keys
wcmd import -n ignition --private-key $LEOPAYS_OWNER_PRIV_KEY
wcmd import -n ignition --private-key $LEOPAYS_ACTIVE_PRIV_KEY
### INSERT system contracts keys
wcmd import -n ignition --private-key $SYSTEMCONTRACTS_OWNER_PRIV_KEY
wcmd import -n ignition --private-key $SYSTEMCONTRACTS_ACTIVE_PRIV_KEY
### INSERT LeoPaysRoBot keys
wcmd import -n ignition --private-key $LEOPAYSROBOT_OWNER_PRIV_KEY
wcmd import -n ignition --private-key $LEOPAYSROBOT_ACTIVE_PRIV_KEY
wcmd import -n ignition --private-key $LEOPAYSROBOT_LEOPAYSROBOT_PRIV_KEY
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


echo ===== Start: $step ============ >> $logfile
curl -X POST http://localhost:$biosport/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' >> $logfile 2>&1

sleep 1
ecmd set contract  lpc  $bioscontractpath eosio.bios.wasm eosio.bios.abi -p lpc@active

sleep 3
# Preactivate all digests
for digest in $FEATURE_DIGESTS; do
    ecmd push action  lpc  activate "{\"feature_digest\":\"$digest\"}" -p lpc@active
done
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))

# Create required system accounts
echo ===== Start: $step ============ >> $logfile
ecmd create account  lpc  lpc.token  $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.ram    $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.ramfee $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.stake  $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.bpay   $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.vpay   $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.upay   $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.names  $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.saving $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.rex    $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.wrap   $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  lpc  lpc.msig   $SYSTEMCONTRACTS_OWNER_PUB_KEY $SYSTEMCONTRACTS_ACTIVE_PUB_KEY -p lpc@active
ecmd create account  leopays  leopaysrobot $LEOPAYSROBOT_OWNER_PUB_KEY $LEOPAYSROBOT_ACTIVE_PUB_KEY -p leopays@active
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))

# set contacts to accounts
echo ===== Start: $step ============ >> $logfile
ecmd set contract  lpc.token  $cnt_dir/eosio.token eosio.token.wasm eosio.token.abi  -p lpc.token@active
ecmd set contract  lpc.msig   $cnt_dir/eosio.msig eosio.msig.wasm eosio.msig.abi     -p lpc.msig@active
ecmd set contract  lpc.wrap   $cnt_dir/eosio.wrap eosio.wrap.wasm eosio.wrap.abi     -p lpc.wrap@active
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


# create, issue & transfer tokens
echo ===== Start: $step ============ >> $logfile
echo executing: leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token create '[ "lpc", "1000000000.0000 LPC" ]' -p lpc.token@active | tee -a $logfile
echo executing: leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token issue '[ "lpc", "20000000.0000 LPC", "init issue" ]'  -p lpc@active | tee -a $logfile
echo executing: leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token transfer '[ "lpc", "leopays", "20000000.0000 LPC", "For LeoPays" ]' -p lpc@active | tee -a $logfile
echo ----------------------- >> $logfile

leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token create '[ "lpc", "1000000000.0000 LPC" ]' -p lpc.token@active >> $logfile 2>&1
leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token issue '[ "lpc", "20000000.0000 LPC", "init issue" ]' -p lpc@active >> $logfile 2>&1
leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc.token transfer '[ "lpc", "leopays", "20000000.0000 LPC", "For LeoPays" ]' -p lpc@active >> $logfile 2>&1
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


# set & init system
echo ===== Start: $step ============ >> $logfile
ecmd set contract  lpc   $cnt_dir/eosio.system eosio.system.wasm eosio.system.abi -p lpc@active
sleep 3
leopays-cli --wallet-url $wdurl --url http://$bioshost:$biosport push action lpc init '[0, "4,LPC"]' -p -p lpc@active >> $logfile 2>&1
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


# create leopaysrobot account
echo ===== Start: $step ============ >> $logfile
ecmd set account permission   leopaysrobot leopaysrobot '{"threshold":1,"keys":[{"key":"'$LEOPAYSROBOT_LEOPAYSROBOT_PUB_KEY'","weight":1}],"accounts":[]}' active  -p leopaysrobot@active
# link auth account@leopaysrobot to leopaysrobot@leopaysrobot
#linkAuthAccountToLeoPaysRoBot account
linkAuthAccountToLeoPaysRoBot leopaysrobot
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


# change permissions lpc & leopays to new keys
echo ===== Start: $step ============ >> $logfile
ecmd set account permission  lpc  owner '{"threshold":1,"keys":[{"key":"'$LPC_OWNER_PUB_KEY'","weight":1}],"accounts":[]}' -p lpc@owner
ecmd set account permission  lpc  active '{"threshold":1,"keys":[{"key":"'$LPC_ACTIVE_PUB_KEY'","weight":1}],"accounts":[]}' owner -p lpc@active

ecmd set account permission  leopays  owner '{"threshold":1,"keys":[{"key":"'$LEOPAYS_OWNER_PUB_KEY'","weight":1}],"accounts":[]}' -p leopays@owner
ecmd set account permission  leopays  active '{"threshold":1,"keys":[{"key":"'$LEOPAYS_ACTIVE_PUB_KEY'","weight":1}],"accounts":[]}' owner -p leopays@active
echo ==== End: $step ============== >> $logfile
step=$(($step + 1))


# update permissions owner & active to another account
#echo ===== Start: $step ============ >> $logfile
#permissionOwner='{"threshold":1,"waits":[],"keys":[],"accounts":[{"permission":{"actor":"lpc","permission":"active"},"weight":1}]}"'
#permissionActive='{"threshold":1,"waits":[],"keys":[],"accounts":[{"permission":{"actor":"lpc","permission":"active"},"weight":1}]}'
#ecmd set account permission   lpc.token active $permissionActive owner  -p lpc.token@owner
#ecmd set account permission   lpc.token owner $permissionOwner   -p lpc.token@owner
#echo ==== End: $step ============== >> $logfile
#step=$(($step + 1))
