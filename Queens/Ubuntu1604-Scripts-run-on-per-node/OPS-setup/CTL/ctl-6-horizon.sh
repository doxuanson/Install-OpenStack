#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh

# Function install the packages
horizon_install () {
	echocolor "Install the packages"
	sleep 3
	apt install openstack-dashboard -y
}


# Function edit the /etc/openstack-dashboard/local_settings.py file
horizon_config () {
	echocolor "Edit the /etc/openstack-dashboard/local_settings.py file"
	sleep 3

	horizonfile=/etc/openstack-dashboard/local_settings.py
	horizonfilebak=/etc/openstack-dashboard/local_settings.py.bak
	cp $horizonfile $horizonfilebak
	egrep -v "^$|^#" $horizonfilebak > $horizonfile

	sed -i 's/OPENSTACK_HOST = "127.0.0.1"/'"OPENSTACK_HOST = \"$HOST_CTL\""'/g' $horizonfile

	echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" >> $horizonfile
	sed -i "s/'LOCATION': '127.0.0.1:11211',/""'LOCATION': '$HOST_CTL:11211',""/g" $horizonfile

	echo "OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True" >> $horizonfile
	cat << EOF >> $horizonfile
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
EOF

	echo 'OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"' >> $horizonfile
	sed -i 's/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"/g' $horizonfile

	sed -i 's/TIME_ZONE = "UTC"/TIME_ZONE = "Asia\/Ho_Chi_Minh"/g' $horizonfile
}

# Function restart installation
horizon_restart () {
	echocolor "Restart installation"
	sleep 3
	service apache2 reload
}

# Function horzion information
horizon_infomation () {
	echocolor "HORIZON INFORMATION"
	echocolor "LOGIN INFORMATION IN HORIZON"
	echocolor "URL: http://$CTL_EXT_IP/horizon"
	echocolor "User: admin (or demo)"
	echocolor "Password: $ADMIN_PASS (or $DEMO_PASS)"
}

#######################
###Execute functions###
#######################

# Install the packages
horizon_install

# Edit the /etc/openstack-dashboard/local_settings.py file
horizon_config

# Restart installation
horizon_restart

# Horzion information
horizon_infomation