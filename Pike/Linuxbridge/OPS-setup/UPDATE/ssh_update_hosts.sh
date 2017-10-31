#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source ../folder-name_config.sh

# Controller
fping $CTL_EXT_IP
if [ $? != "0" ]
then
	echocolor "Node Controller not known"
	exit 1;
fi
scp -i ../$FOLDER_KEY_NAME/mykey -r ../../$FOLDER_ROOT_NAME root@$CTL_EXT_IP:
ssh -t -t -i ../$FOLDER_KEY_NAME/mykey root@$CTL_EXT_IP "cd $FOLDER_ROOT_NAME/$UPDATE_FOLDER_NAME && source update_hosts.sh"

# Compute
for (( i=1; i <= ${#HOST_COM[*]}; i++ ))
do
	fping ${COM_EXT_IP[$i]}
	if [ $? != "0" ]
	then
		echocolor "Node ${HOST_COM[$i]} not known"
		continue
	fi
	sshpass -p ${COM_PASS[$i]} scp -r ../../$FOLDER_ROOT_NAME root@${COM_EXT_IP[$i]}:
	sshpass -p ${COM_PASS[$i]} ssh -t -t root@${COM_EXT_IP[$i]} "cd $FOLDER_ROOT_NAME/$UPDATE_FOLDER_NAME && source update_hosts.sh"
	
done

# Block
for (( i=1; i <= ${#HOST_BLK[*]}; i++ ))
do
	fping ${BLK_EXT_IP[$i]}
	if [ $? != "0" ]
	then
		echocolor "Node ${HOST_BLK[$i]} not known"
		continue
	fi
	sshpass -p ${BLK_PASS[$i]} scp -r ../../$FOLDER_ROOT_NAME root@${BLK_EXT_IP[$i]}:
	sshpass -p ${BLK_PASS[$i]} ssh -t -t root@${BLK_EXT_IP[$i]} "cd $FOLDER_ROOT_NAME/$UPDATE_FOLDER_NAME && source update_hosts.sh"
	
done
