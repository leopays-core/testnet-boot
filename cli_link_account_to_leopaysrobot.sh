#!/bin/bash

# set up a wallet just for holding the key used during blockchain ignition

###INSERT envars
. ./.environment-cli

ACCOUNT=$1
if [[ -n "$ACCOUNT" ]]
then
    ecmd set account permission  $ACCOUNT  leopaysrobot '{"threshold":1,"keys":[],"accounts":[{"permission":{"actor":"leopaysrobot","permission":"leopaysrobot"},"weight":1}]}' active
    linkAuthAccountToLeoPaysRoBot $ACCOUNT
else
    echo "!Account name expected!"
    exit
fi
