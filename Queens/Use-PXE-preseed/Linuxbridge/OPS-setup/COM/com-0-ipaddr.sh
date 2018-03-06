#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source com_num.sh

# Function config COMPUTE node
config_hostname () {
	echo "${HOST_COM[$COM_NUM]}" > /etc/hostname
	hostnamectl set-hostname ${HOST_COM[$COM_NUM]}

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
auto ${COM_EXT_IF[$COM_NUM]}
iface ${COM_EXT_IF[$COM_NUM]} inet static
address ${COM_EXT_IP[$COM_NUM]}
netmask ${COM_EXT_NETMASK[$COM_NUM]}
gateway $GATEWAY_EXT_IP
dns-nameservers 8.8.8.8

# internal network interface
auto ${COM_MGNT_IF[$COM_NUM]}
iface ${COM_MGNT_IF[$COM_NUM]} inet static
address ${COM_MGNT_IP[$COM_NUM]}
netmask ${COM_MGNT_NETMASK[$COM_NUM]}
EOF
	 

	ip a flush ${COM_EXT_IF[$COM_NUM]}
	ip a flush ${COM_MGNT_IF[$COM_NUM]}
	ip r del default
	ifdown -a && ifup -a
}

#######################
###Execute functions###
#######################

# Config COMPUTE node
echocolor "Config COMPUTE node"
sleep 3
## Config hostname
config_hostname

## IP address
config_ip