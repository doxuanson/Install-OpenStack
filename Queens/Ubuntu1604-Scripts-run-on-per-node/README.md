# Cài đặt OpenStack Queens trên Ubuntu Server 16.04


# MỤC LỤC
- [1.Mô hình](#1mô-hình)
- [2.IP Planning](#2ip-planning)
- [3.Cài đặt thủ công](#3cài-đặt-thủ-công)
- [4.Thực hiện chạy scripts trên từng node Controller và Compute](#4thực-hiện-chạy-scripts-trên-từng-node-controller-và-compute)
- [5.Chú ý khi cài OpenStack phiên bản Queens sử dụng OpenvSwitch trên Ubuntu Server 16.04](#5chú-ý-khi-cài-openstack-phiên-bản-queens-sử-dụng-openvswitch-trên-ubuntu-server-1604)
  - [5.1.Chú ý 1](#51chú-ý-1)
  - [5.2.Chú ý 2](#52chú-ý-2)



# 1.Mô hình
\- Mô hình cài đặt OpenStack Queens gồm 1 node Controller, nhiều node Compute.  
\- Cài đặt các project: Keystone, Glance, Nova, Neutron, Horizon.  

<img src="images/mo-hinh.png" />

# 2.IP Planning
Yêu cầu phần cứng và địa chỉ IP cho các nodes.  
<img src="images/ip_planning_1.png" />

# 3.Cài đặt thủ công
\- Tham khảo:
- https://docs.openstack.org/queens/install/
- https://docs.openstack.org/ocata/networking-guide/deploy.html

# 4.Thực hiện chạy scripts trên từng node Controller và Compute
\- Trên tất các node:
- Thực hiện đặt mật khẩu người dùng `root` trên tất cả các node sao cho giống nhau, ở đây mình đặt là `welcome123`.  
- Download các file shell scripts. Thực hiện các câu lệnh sau:  
```
apt install subversion -y
svn export https://github.com/doxuanson/Install-OpenStack/trunk/Queens/Ubuntu1604-Scripts-run-on-per-node/OPS-setup
```

- Set quyền `755` cho các files đó.  
```
chmod -R 755 OPS-setup
```

- Thay đổi nội dung các file `OPS-setup/config.sh` theo mô hình của bạn.
- Trên node Controller, thực hiện lệnh:  
```
cd OPS-setup/CTL
source ctl-0-ipaddr.sh
init 6
```

- Trên các node Compute, thực hiện lệnh:   
```
cd OPS-setup/COM
source com-0-ipaddr.sh
init 6
```


\- Đứng từ một máy ở cùng dải mạng với interface `eth2` của các node, thực hiện ssh đến người dùng `root` của các node:  
- Trên node Controller, thực hiện lệnh:  
```
cd OPS-setup/CTL
source ctl-all.sh
```

- Sau khi cài đặt xong node Controller, chuyển sang các node Compute, sửa file `OPS-setup/COM/com_num.sh` tương ứng với số thú tự node Compute, thực hiện lệnh:  
```
cd OPS-setup/COM
source com-all.sh
```

# 5.Chú ý khi cài OpenStack phiên bản Queens sử dụng OpenvSwitch trên Ubuntu Server 16.04
\- Quá trình cài theo docs:  
- https://docs.openstack.org/queens/install/
- https://docs.openstack.org/ocata/networking-guide/deploy.html

nhưng có 1 số chỗ bổ sung.  

## 5.1.Chú ý 1
\- Trên node Controller, sau khi thực hiện lệnh:  
```
apt install neutron-server neutron-plugin-ml2 \
	neutron-openvswitch-agent neutron-l3-agent neutron-dhcp-agent \
	neutron-metadata-agent -y
```

ta cần restart lại dịch vụ openvswitch:  
```
systemctl restart openvswitch-switch
```

\- Trên node Compute, sau khi thực hiện lệnh:  
```
apt install neutron-openvswitch-agent -y
```

ta cần restart lại dịch vụ openvswitch:  
```
systemctl restart openvswitch-switch
```

## 5.2.Chú ý 2
\- Thực hiện cài OpenStack bằng scripts trên lần lượt từng Compute, cài đặt xong trên `Compute1` rồi tiếp tục đến `Compute2`.  Vì khi thực đến lệnh:  
```
echocolor "Update"
source com-update.sh
```

trong file `OPS-setup/COM/com-all.sh`. Lệnh này có chứa tiến trình copy thư mục `OPS-setup` sang tất cả các node, mà nếu một node nào đó cũng đang sử dụng thư `OPS-setup` thì sẽ gây ra hiện tượng **xung đột**.  




