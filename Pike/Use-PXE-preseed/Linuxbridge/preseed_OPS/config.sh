#!/bin/bash
#Author Son Do Xuan

##########################################
#### Set local variable  for scripts #####
##########################################

# Variable
## IP address of COBBLER, APT_CACHE_SERVER and path for repo Ubuntu
COBBLER_IP=172.16.69.101
APT_CACHE_SERVER=172.16.69.101
REPO_HOSTNAME=http://172.16.69.101
REPO_FOLDER=/ubuntu-16.04

## Folder name contain scripts to install OpenStack
PATH_OPSsetup="OPS-setup"

## User name, user password and root password
USER_NAME=ubuntu
USER_PASS=son123456
ROOT_PASS=son123456

## Compute number and Block number
com_num=1
blk_num=1