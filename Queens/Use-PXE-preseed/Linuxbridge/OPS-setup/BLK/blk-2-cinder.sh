#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh
source blk_num.sh

# Function install lvm2
cinder_install_lvm () {
	echocolor "Install lvm2"
	sleep 3
	apt install lvm2 -y
}

# Function config lvm
cinder_config_lvm () {
	echocolor "Config lvm"
	for x in ${BLK_DISK[$BLK_NUM]}
	do
		pvcreate /dev/$x
	done

	string1=""
	for x in ${BLK_DISK[$BLK_NUM]}
	do
		string1="$string1 /dev/$x"
	done

	vgcreate cinder-volumes $string1
		
	string2=""
	for x in ${BLK_DISK[$BLK_NUM]}
	do
			string2="$string2\"a/$x/\", "
	done

	string2="filter = [ $string2 \"r/.*/\"]"

	lvmfile=/etc/lvm/lvm.conf
#	sed -i '142i'"$string2" $lvmfile
	sed -i 's|# Accept every block device:|'"$string2"'|g' $lvmfile
}

# Function install cinder-volume
cinder_install_cinder-volume () {
	echocolor "Install cinder-volume"
	sleep 3
	apt install cinder-volume -y
	apt install thin-provisioning-tools -y
}

# Function config /etc/cinder/cinder.conf
cinder_config () {
	echocolor "Config /etc/cinder/cinder.conf"
	cinderapifile=/etc/cinder/cinder.conf
	cinderapifilebak=/etc/cinder/cinder.conf.bak
	cp $cinderapifile $cinderapifilebak
	egrep -v "^#|^$"  $cinderapifilebak > $cinderapifile
	
	ops_del $cinderapifile database connection
	ops_add $cinderapifile database \
		connection mysql+pymysql://cinder:$CINDER_DBPASS@$HOST_CTL/cinder

	ops_add $cinderapifile DEFAULT \
		transport_url rabbit://openstack:$RABBIT_PASS@$HOST_CTL
		
	cat << EOF >> $cinderapifile
[keystone_authtoken]
# ...
auth_uri = http://$HOST_CTL:5000
auth_url = http://$HOST_CTL:35357
memcached_servers = $HOST_CTL:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = $CINDER_PASS
EOF

	ops_add $cinderapifile DEFAULT my_ip ${BLK_MGNT_IP[$BLK_NUM]}

	cat << EOF >> $cinderapifile
[lvm]
# ...
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-volumes
iscsi_protocol = iscsi
iscsi_helper = tgtadm
EOF
	
	ops_add $cinderapifile DEFAULT enabled_backends lvm
	ops_add $cinderapifile DEFAULT glance_api_servers http://$HOST_CTL:9292

	cat << EOF >> $cinderapifile
[oslo_concurrency]
# ...
lock_path = /var/lib/cinder/tmp
EOF
}

# Function cinder restart
cinder_restart () {
	echocolor "Cinder restart"
	service tgt restart
	service cinder-volume restart
}

#######################
###Execute functions###
#######################

# Function install lvm2
cinder_install_lvm

# Function config lvm
cinder_config_lvm

# Function install cinder-volume
cinder_install_cinder-volume

# Function config /etc/cinder/cinder.conf
cinder_config

# Function cinder restart
cinder_restart


