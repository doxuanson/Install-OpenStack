#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh

# Function config hostname
config_hostname () {
	echo "$HOST_CTL" > /etc/hostname
	hostnamectl set-hostname $HOST_CTL

	cat << EOF >/etc/hosts
127.0.0.1	localhost

$CTL_MGNT_IP	$HOST_CTL
EOF

	for (( i=1; i <= ${#HOST_COM[*]}; i++ ))
	do
		echo "${COM_MGNT_IP[$i]}	${HOST_COM[$i]}" >> /etc/hosts
	done
	
	for (( i=1; i <= ${#HOST_BLK[*]}; i++ ))
	do
		echo "${BLK_MGNT_IP[$i]}	${HOST_BLK[$i]}" >> /etc/hosts
	done
}

# Function IP address
config_ip () {
	cat << EOF > /etc/network/interfaces
# loopback network interface
auto lo
iface lo inet loopback

# Provider network interface
auto $CTL_EXT_IF
iface $CTL_EXT_IF inet static
address $CTL_EXT_IP
netmask $CTL_EXT_NETMASK
gateway $GATEWAY_EXT_IP
dns-nameservers 8.8.8.8

# MNGT network interface
auto $CTL_MGNT_IF
iface $CTL_MGNT_IF inet static
address $CTL_MGNT_IP
netmask $CTL_MGNT_NETMASK

# DATAVM network interface
auto $CTL_DATAVM_IF
iface $CTL_DATAVM_IF inet static
address $CTL_DATAVM_IP
netmask $CTL_DATAVM_NETMASK
EOF

	ip a flush $CTL_EXT_IF
	ip a flush $CTL_MGNT_IF
	ip a flush $CTL_DATAVM_IF
	systemctl restart networking
}

#######################
###Execute functions###
#######################

# Config CONTROLLER node
echocolor "Config CONTROLLER node"
sleep 3

## Config hostname
config_hostname

## IP address
config_ip
