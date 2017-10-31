#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source blk_num.sh
source ../folder-name_config.sh

source sshkey_setup.sh

scp -i ../$FOLDER_KEY_NAME/mykey -r ../../$FOLDER_ROOT_NAME root@${BLK_EXT_IP[$BLK_NUM]}:
ssh -t -t -i ../$FOLDER_KEY_NAME/mykey root@${BLK_EXT_IP[$BLK_NUM]} "cd $FOLDER_ROOT_NAME/$BLK_FOLDER_NAME && source blk-all.sh"

if [ $BLK_NUM = 1 ]
then
	ssh -t -t -i ../$FOLDER_KEY_NAME/mykey root@$CTL_EXT_IP "cd $FOLDER_ROOT_NAME/$CTL_FOLDER_NAME && source ctl-cinder.sh"
fi

cd ../$UPDATE_FOLDER_NAME
source ssh_update_hosts.sh
