#!/bin/bash
#Author Son Do Xuan

source ../function.sh
source ../config.sh

# Function create database for Heat
heat_create_db () {
	echocolor "Create database for Heat"
	sleep 3

	cat << EOF | mysql
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' \
  IDENTIFIED BY '$HEAT_DBPASS';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' \
  IDENTIFIED BY '$HEAT_DBPASS';
EOF
}

# Function create the Heat service credentials
heat_create_service () {
	echocolor "Set variable environment for admin user"
	sleep 3
	source /root/admin-openrc

	echocolor "Create the service credentials"
	sleep 3

	openstack user create --domain default --password $HEAT_PASS heat
	openstack role add --project service --user heat admin
	openstack service create --name heat \
		--description "Orchestration" orchestration
	openstack service create --name heat-cfn \
		--description "Orchestration"  cloudformation
		
	openstack endpoint create --region RegionOne \
		orchestration public http://controller:8004/v1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne \
		orchestration internal http://controller:8004/v1/%\(tenant_id\)s
	openstack endpoint create --region RegionOne \
		orchestration admin http://controller:8004/v1/%\(tenant_id\)s
	
	openstack endpoint create --region RegionOne \
		cloudformation public http://controller:8000/v1
	openstack endpoint create --region RegionOne \
		cloudformation internal http://controller:8000/v1
	openstack endpoint create --region RegionOne \
		cloudformation admin http://controller:8000/v1
}

# Function additional information in the Identity service to manage stacks
heat_add_info () {
	openstack domain create --description "Stack projects and users" heat
	openstack user create --domain heat --password $HEAT_DOMAIN_ADMIN_PASS heat_domain_admin
	openstack role add --domain heat --user-domain heat --user heat_domain_admin admin
	openstack role create heat_stack_owner
	openstack role add --project demo --user demo heat_stack_owner
	openstack role create heat_stack_user
}

# Function install components of Heat
heat_install () {
	echocolor "Install and configure components of Heat"
	sleep 3

	apt-get install heat-api heat-api-cfn heat-engine -y
}

# Function config /etc/heat/heat.conf file
heat_config () {
	heatapifile=/etc/heat/heat.conf
	heatapifilebak=/etc/heat/heat.conf.bak
	cp $heatapifile $heatapifilebak
	egrep -v "^#|^$"  $heatapifilebak > $heatapifile
	
	ops_add $heatapifile database \
		connection mysql+pymysql://heat:$HEAT_DBPASS@$HOST_CTL/heat

	ops_add $heatapifile DEFAULT \
		transport_url rabbit://openstack:$RABBIT_PASS@$HOST_CTL
	
	ops_add $heatapifile keystone_authtoken \
		auth_uri http://$HOST_CTL:5000
	  
	ops_add $heatapifile keystone_authtoken \
		auth_url http://$HOST_CTL:35357

	ops_add $heatapifile keystone_authtoken \
		memcached_servers $HOST_CTL:11211
	  
	ops_add $heatapifile keystone_authtoken \
		auth_type password
	  
	ops_add $heatapifile keystone_authtoken \
		project_domain_name default

	ops_add $heatapifile keystone_authtoken \
		user_domain_name default

	ops_add $heatapifile keystone_authtoken \
		project_name service
		
	ops_add $heatapifile keystone_authtoken \
		username heat

	ops_add $heatapifile keystone_authtoken \
		password $HEAT_PASS
	
	ops_add $heatapifile trustee \
		auth_type password
	ops_add $heatapifile trustee \
		auth_url http://$HOST_CTL:35357
	ops_add $heatapifile trustee \
		username heat
	ops_add $heatapifile trustee \
		password $HEAT_PASS
	ops_add $heatapifile trustee \
		user_domain_name default
		
	ops_add $heatapifile clients_keystone \
		auth_uri http://$HOST_CTL:35357

	ops_add $heatapifile ec2authtoken \
		auth_uri http://$HOST_CTL:5000/v3

	ops_add $heatapifile DEFAULT \
		stack_domain_admin heat_domain_admin
	ops_add $heatapifile DEFAULT \
		stack_domain_admin_password $HEAT_DOMAIN_ADMIN_PASS
	ops_add $heatapifile DEFAULT \
		stack_user_domain_name heat
}

# Function populate the Orchestration database
heat_populate_db () {
	echocolor "Populate the Orchestration database"
	sleep 3
	su -s /bin/sh -c "heat-manage db_sync" heat
}

# Function restart the Image services
heat_restart () {
	echocolor "Restart the Orchestration services"
	sleep 3

	service heat-api restart
	service heat-api-cfn restart
	service heat-engine restart
}

#######################
###Execute functions###
#######################

# Function create database for Heat
heat_create_db

# Function create the Heat service credentials
heat_create_service

# Function additional information in the Identity service to manage stacks
heat_add_info

# Function install components of Heat
heat_install

# Function config /etc/heat/heat.conf file
heat_config

# Function populate the Orchestration database
heat_populate_db

# Function restart the Image services
heat_restart

