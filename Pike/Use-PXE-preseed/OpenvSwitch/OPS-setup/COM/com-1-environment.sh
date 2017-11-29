#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source com_num.sh

# Function update and upgrade for COMPUTE
update_upgrade () {
	echocolor "Update and Upgrade COMPUTE"
	sleep 3
	apt-get update -y && apt-get upgrade -y
}

# Function install crudini
install_crudini () {
	echocolor "Install crudini"
	sleep 3
	apt-get install -y crudini
}

# Function install and config NTP
install_ntp () {
	echocolor "Install NTP"
	sleep 3

	apt-get install chrony -y
	ntpfile=/etc/chrony/chrony.conf

	sed -i 's|'"pool 2.debian.pool.ntp.org offline iburst"'| \
'"server $HOST_CTL iburst"'|g' $ntpfile

	service chrony restart
}

# Function install OpenStack packages (python-openstackclient)
install_ops_packages () {
	echocolor "Install OpenStack client"
	sleep 3
	apt-get install software-properties-common -y
	add-apt-repository cloud-archive:pike -y
	apt-get update -y && apt-get dist-upgrade -y

	apt-get install python-openstackclient -y
}

#######################
###Execute functions###
#######################

# Update and upgrade for COMPUTE
update_upgrade

# Install crudini
install_crudini

# Install and config NTP
install_ntp

# Install OpenStack packages (python-openstackclient)
install_ops_packages

