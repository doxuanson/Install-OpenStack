#!/bin/bash
source config.sh

cat <<HERE > ks_CTL.cfg
#Generic Kickstart template for Ubuntu
#Platform: x86 and x86-64

#System language
lang en_US

#Language modules to install
langsupport en_US

#System keyboard
keyboard us

#System timezone
timezone Asia/Ho_Chi_Minh

#Root password
rootpw $ROOT_PASS

#Initial user (user with sudo capabilities) 
user $USER_NAME --fullname "Ubuntu User" --password $USER_PASS

#System authorization infomation
auth  --useshadow  --enablemd5 

#Reboot after installation
reboot

#Use text mode install
text

#System bootloader configuration
bootloader --location=mbr

#Partition clearing information
clearpart --all

#Basic disk partition
part / --fstype ext4 --size 5 --grow --asprimary
part swap --size 1024
part /boot --fstype ext4 --size 256

#Network information
network --bootproto=dhcp --hostname ubuntu

# config repo source.list
url --url $REPO_PATH

#Do not configure the X Window System
skipx

# Install packet for the system
%packages  --ignoremissing
@ ubuntu-server
openssh-server

# Run script after installation
%post
# Grub
sed -i 's/GRUB_HIDDEN_TIMEOUT=0/#GRUB_HIDDEN_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet splash//g' /etc/default/grub
update-grub

## Config ssh
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

##Config repo
sed -i "s|$REPO_PATH|http://vn.archive.ubuntu.com/ubuntu|g" /etc/apt/sources.list
apt-get update -y && apt-get upgrade -y

cp /etc/rc.local /etc/rc.local.bak
chmod 755 /etc/rc.local

	cat << EOF > /etc/rc.local
#!/bin/bash
echo -e "Acquire::http::Proxy \"http://$APT_CACHE_SERVER:3142\";" >/etc/apt/apt.conf.d/00aptproxy
apt update -y && apt upgrade -y

cd /root
wget --no-parent --recursive -nH --reject="index.html*" http://$COBBLER_IP/$PATH_OPSsetup/

cd /root/OPS-setup/CTL
source ctl-all.sh
rm /etc/apt/apt.conf.d/00aptproxy
rm /etc/rc.local
mv /etc/rc.local.bak /etc/rc.local
exit 0
EOF
%end

HERE