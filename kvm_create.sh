#!/bin/bash
read -p "创建虚拟机名字:" name
qemu-img create -b /var/lib/libvirt/images/.node_base.qcow2 -f qcow2 /var/lib/libvirt/images/${name}.img 20G
cp qemu.xml  /etc/libvirt/qemu/${name}.xml
sed -i "/<name>/s/node_base/$name/" /etc/libvirt/qemu/${name}.xml
sed -i "/source file/s/node_base/$name/" /etc/libvirt/qemu/${name}.xml
virsh define /etc/libvirt/qemu/${name}.xml
