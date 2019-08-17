#!/bin/bash
virsh list --all
read -p "请选择要删除的虚拟机:" name
if [ "$name" == "" ];then
    echo "不能为空,请重新输入! 0.0~" && exit
elif [ "$name" != "" ];then
    for i in `virsh list --all --name`
    do
       if [ ${name} ==  $i ];then
	  a=$name && break
       else
          continue
       fi
    done
    if [ "$a" == "$name" ];then
	  virsh destroy $name &> /dev/null
	  virsh undefine $name &> /dev/null
	  rm -rf /var/lib/libvirt/images/${name}.img && echo "删除成功!" 
	  exit 1
    else
	  echo "输入名字有误"
    fi
fi
