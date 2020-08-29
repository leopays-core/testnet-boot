#!/bin/bash

. ./.environment

$DCcli --wallet-url $wdurl --url http://$bioshost:$biosport $*
