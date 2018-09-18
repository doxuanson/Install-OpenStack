#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh

echocolor "IP address"
source ctl-0-ipaddr.sh

echocolor "Environment"
source ctl-1-environment.sh

echocolor "Keystone"
source ctl-2-keystone.sh

echocolor "Glance"
source ctl-3-glance.sh

echocolor "Nova"
source ctl-4-nova.sh

echocolor "Neutron"
source ctl-5-neutron-selfservice.sh

echocolor "Horizon"
source ctl-6-horizon.sh

echocolor "Create Network and Flavor"
source ctl-7-create_network.sh
