# Một số chú ý khi cài OpenStakc phiên bản Pike với Linux bridge
Quá trình cài theo docs https://docs.openstack.org/pike/install/ nhưng có 1 số chỗ bổ sung:  

## Project Cinder
- Trên node Storage, cài thêm phần mềm `thin-provisioning-tools` khi cài cinder-volume:  
```
apt install cinder-volume -y
apt install thin-provisioning-tools -y
```

