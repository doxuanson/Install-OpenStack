#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source blk_num.sh

echocolor "IP address"
source blk-0-ipaddr.sh

echocolor "Environment"
source blk-1-environment.sh

echocolor "Cinder"
source blk-2-cinder.sh

echocolor "Update"
source block-update.sh
