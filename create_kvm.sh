#!/bin/bash
qcowfile=/var/lib/libvirt/images
xmlfile=/etc/libvirt/qemu
read -p "创建虚拟机名字: " name
#read -p "设置虚拟机ip: " ip
#read -p "虚拟机主机名: " hostname
if [ -e ${qcowfile}/${name}.img ];then
	echo_warning
	echo "vm ${name}已存在" 
	return 1
else
	qemu-img create -b ${qcowfile}/.node_base.qcow2 -f qcow2 ${qcowfile}/${name}.img 20G  &>/dev/null
	cp qemu.xml  ${xmlfile}/${name}.xml
	sed -i "/<name>/s/node_base/$name/" /etc/libvirt/qemu/${name}.xml
	sed -i "/source file/s/node_base/$name/" /etc/libvirt/qemu/${name}.xml
	virsh define ${xmlfile}/${name}.xml &>/dev/null
	echo "vm ${name}创建成功"
fi
virsh start $name &>/dev/null
sleep 15
read -p "设置虚拟机网卡 eth0|eth1|eth2|eth3: " eth
read -p "设置虚拟机ip: " ip
read -p "设置虚拟机主机名: " hostname
expect << EOF
spawn virsh console $name
expect "]"    {send "\r"}
expect ":"    {send "root\r"}
expect "Password:"    {send "a\r"}
expect "#"    {send "echo 'IPADDR=$ip
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
' >> /etc/sysconfig/network-scripts/ifcfg-eth$eth\r"}
expect "#"    {send "sed -i 's/dhcp/static/' /etc/sysconfig/network-scripts/ifcfg-eth$eth\r"}
expect "#"          { send "hostnamectl set-hostname $hostname\r" }
expect "#"    {send "systemctl restart network\r"}
expect "#"          { send "exit\r" }
EOF
#
#mountpoint=/mnt/virimage/
#if mount |grep -q "$mountpoint" ;then
#umount $mountpoint
#fi
#guestmount -a /var/lib/libvirt/images/${name}.img -i /mnt/virimage &> /dev/null
##guestmount -d $name -i $mountpoint
#echo $hostname > /mnt/virimage/etc/hostname
#echo "TYPE=Ethernet
#PROXY_METHOD=none
#BROWSER_ONLY=no
#BOOTPROTO=none
#DEFROUTE=yes
#NAME=$eth
#DEVICE=$eth
#ONBOOT=yes
#IPADDR=$ip
#PREFIX=$submask
#IPV4_FAILURE_FATAL=no
#IPV6INIT=no" > /mnt/virimage/etc/sysconfig/network-scripts/ifcfg-$eth
#	virsh define ${xmlfile}/${name}.xml &>/dev/null
#virsh start $name
