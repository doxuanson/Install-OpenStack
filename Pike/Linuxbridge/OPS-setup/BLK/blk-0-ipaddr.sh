#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source blk_num.sh

# Function config BLOCK node
config_hostname () {
	echo "${HOST_BLK[$BLK_NUM]}" > /etc/hostname
	hostnamectl set-hostname ${HOST_BLK[$BLK_NUM]}

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

# external network interface
auto ${BLK_EXT_IF[$BLK_NUM]}
iface ${BLK_EXT_IF[$BLK_NUM]} inet static
address ${BLK_EXT_IP[$BLK_NUM]}
netmask ${BLK_EXT_NETMASK[$BLK_NUM]}
gateway $GATEWAY_EXT_IP
dns-nameservers 8.8.8.8

# internal network interface
auto ${BLK_MGNT_IF[$BLK_NUM]}
iface ${BLK_MGNT_IF[$BLK_NUM]} inet static
address ${BLK_MGNT_IP[$BLK_NUM]}
netmask ${BLK_MGNT_NETMASK[$BLK_NUM]}
EOF
	 

	ip a flush ${BLK_EXT_IF[$BLK_NUM]}
	ip a flush ${BLK_MGNT_IF[$BLK_NUM]}
	ip r del default
	ifdown -a && ifup -a
}

#######################
###Execute functions###
#######################

# Config BLOCK node
echocolor "Config BLOCK node"
sleep 3
## Config hostname
config_hostname

## IP address
config_ip