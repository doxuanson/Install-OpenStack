\- Khi mình sử dụng PXE để cài OpenStack phiên bản Pike với Open vSwitch, mình đã viết lệnh chạy scripts đó vào file /etc/rc.local để tự động cài OpenStack sau khi boot xong hệ điều hành.  
Điều này dẫn đến lỗi database của Open vSwitch khi cài các gói phần mềm cho project Neutron trên cả node Controller và Compute, vì vậy ta phải thêm lệnh restart openvswitch vào sau lệnh cài các gói phần mềm Neutron như sau:  
```
apt install neutron-server neutron-plugin-ml2 \
    neutron-openvswitch-agent neutron-l3-agent neutron-dhcp-agent \
    neutron-metadata-agent -y
systemctl restart openvswitch-switch
```


