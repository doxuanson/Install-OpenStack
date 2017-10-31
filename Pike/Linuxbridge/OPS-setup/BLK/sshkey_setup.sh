#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source blk_num.sh
source ../folder-name_config.sh

apt-get install fping -y
fping ${BLK_EXT_IP[$BLK_NUM]}
if [ $? != "0" ]
then
	echocolor "Node BLOCK not known"
	exit 1;
fi

apt-get install sshpass -y
sshpass -p ${BLK_PASS[$BLK_NUM]} ssh-copy-id -i ../$FOLDER_KEY_NAME/mykey.pub root@${BLK_EXT_IP[$BLK_NUM]}

ssh -i ../$FOLDER_KEY_NAME/mykey root@${BLK_EXT_IP[$BLK_NUM]} <<EOF
# Update and upgrade for BLOCK
echo -e "\e[32mUpdate and Upgrade BLOCK \e[0m"
sleep 3
apt-get update -y && apt-get upgrade -y

# OpenStack packages (python-openstackclient)
echo -e "\e[32mInstall OpenStack client \e[0m"
sleep 3
apt-get install software-properties-common -y
add-apt-repository cloud-archive:pike -y
apt-get update -y && apt-get dist-upgrade -y

apt-get install python-openstackclient -y
EOF