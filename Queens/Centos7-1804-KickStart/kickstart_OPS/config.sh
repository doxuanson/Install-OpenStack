#!/bin/bash
#Author Son Do Xuan

##########################################
#### Set local variable  for scripts #####
##########################################

# Variable
## IP address of COBBLER, APT_CACHE_SERVER and path for repo Ubuntu
COBBLER_IP=172.16.69.21
REPO_HOSTNAME=http://172.16.69.21
REPO_FOLDER=/cblr/links/Centos7-x86_64

## Folder name contain scripts to install OpenStack
PATH_OPSsetup="OPS-setup"

## Folder name OPS
FOLDER_ROOT_NAME=OPS-setup
CTL_FOLDER_NAME=CTL
COM_FOLDER_NAME=COM
BLK_FOLDER_NAME=BLK
UPDATE_FOLDER_NAME=UPDATE

## User name, user password and root password
USER_NAME=centos
USER_PASS=welcome123
ROOT_PASS=welcome123

## Compute number and Block number
com_num=1
blk_num=1