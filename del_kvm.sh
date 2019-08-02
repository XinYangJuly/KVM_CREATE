#!/bin/bash
virsh list --all
read -p "选择要删除的虚拟机:" name
if [ $name == ""];then
	echo "不能为空:" && exit
fi
virsh destroy $name &> /dev/null
virsh undefine $name
rm -rf /var/lib/libvirt/images/${name}.img
