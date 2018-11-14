#!/bin/bash
source config.sh

cat <<HERE > ps_CTL.seed
#### Contents of the preconfiguration file (for xenial)

### Localization
# Preseeding only locale sets language, country and locale.
d-i debian-installer/locale string en_US

# Keyboard selection
#d-i console-setup/ask_detect boolean false
#d-i keyboard-configuration/xkb-keymap select us

### Network configuration
#d-i netcfg/choose_interface select auto
#d-i netcfg/get_hostname string ubuntu

### Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string $REPO_HOSTNAME
d-i mirror/http/directory string $REPO_FOLDER
d-i mirror/http/proxy string

### Account setup
d-i passwd/root-login boolean true
d-i passwd/make-user boolean true

# Root password, either in clear text
d-i passwd/root-password password $ROOT_PASS
d-i passwd/root-password-again password $ROOT_PASS

# To create a normal user account.
d-i passwd/user-fullname string Ubuntu User
d-i passwd/username string $USER_NAME
d-i passwd/user-password password $USER_PASS
d-i passwd/user-password-again password $USER_PASS
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# Set to true if you want to encrypt the first user's home directory.
d-i user-setup/encrypt-home boolean false

### Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string Asia/Ho_Chi_Minh

d-i clock-setup/ntp boolean true
d-i clock-setup/ntp-server string ntp.ubuntu.com

### Partitioning
d-i partman-auto/method string regular
d-i partman-auto/disk string /dev/[svh]da
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

### Package selection
tasksel tasksel/first multiselect openssh-server
d-i pkgsel/upgrade select none
d-i pkgsel/update-policy select none

### Boot loader installation
d-i grub-installer/only_debian boolean true

# To install to the first device (assuming it is not a USB stick):
d-i grub-installer/bootdev string default

# Verbose output and no boot splash screen.
d-i	debian-installer/quiet	boolean false
d-i	debian-installer/splash	boolean false
d-i debian-installer/add-kernel-opts string biosdevname=0 net.ifnames=0

### Finishing up the installation
# Avoid that last message about the install being complete.
d-i finish-install/reboot_in_progress note

### Post Installer
d-i preseed/late_command string \\
# Config ssh
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /target/etc/ssh/sshd_config; \\
#Config repo
sed -i "s|$REPO_HOSTNAME$REPO_FOLDER|http://vn.archive.ubuntu.com/ubuntu|g" /target/etc/apt/sources.list; \\
apt-get update -y && apt-get upgrade –y; \\

echo -e "Acquire::http::Proxy \"http://$CACHER_SERVER:3142\";" > /target/etc/apt/apt.conf.d/00aptproxy; \\
cp /target/etc/rc.local /target/etc/rc.local.bak; \\
chmod 755 /target/etc/rc.local; \\
echo -e "#!/bin/bash" > /target/etc/rc.local; \\
echo -e "apt update -y && apt upgrade -y" >> /target/etc/rc.local; \\

echo -e "cd /root" >> /target/etc/rc.local; \\
echo -e "wget --no-parent --recursive -nH --reject=\"index.html*\" $PATH_OPSsetup/" >> /target/etc/rc.local; \\

echo -e "cd /root/OPS-setup/CTL" >> /target/etc/rc.local; \\
echo -e "source ctl-all.sh" >> /target/etc/rc.local; \\
echo -e "rm /etc/apt/apt.conf.d/00aptproxy" >> /target/etc/rc.local; \\
echo -e "rm /etc/rc.local" >> /target/etc/rc.local; \\
echo -e "mv /etc/rc.local.bak /etc/rc.local" >> /target/etc/rc.local; \\

echo -e "exit 0" >> /target/etc/rc.local

HERE