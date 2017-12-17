#########################################################################
# File Name: kvm_setup.sh
# Created Time: Mon 12 Oct 2015 07:59:41 PM HKT
# 需要安装guestfs-tools 直接操作镜像文件修改基础配置,以宿主ip末尾为0，递加上为虚机ip
#########################################################################
#!/bin/bash

#KVMHOST_IP=`ifconfig br0|grep "inet "|awk -F":| " '{print $13}'`
KVMHOST_IP=`ifconfig br0|awk -F":| " '/inet/ {print $13}'`
D_KVMHOST_IP=`echo $KVMHOST_IP | awk -F. '{print $4}'`
C_KVMHOST_IP=`echo $KVMHOST_IP | awk -F. '{print $3}'`

if [ ${#C_KVMHOST_IP} -eq 1 ]
then
	HOST_AREA=inner
elif [ ${#C_KVMHOST_IP} -eq 2 ]
then
	HOST_AREA=sjc
elif [ ${#C_KVMHOST_IP} -eq 3 ]
then
	HOST_AREA=fd
else
	echo "Unknow host area!"
	exit 1
fi

ABC_KVMHOST_IP=`echo $KVMHOST_IP | awk -F. '{print $1"."$2"."$3"."}'`
LASTNUM_OF_IP=`echo ${KVMHOST_IP:0-1}`
KVMHOST_GW=`ip r s 0/0|awk '{print $3}'`

if [ $LASTNUM_OF_IP -ne 0 ]
then
	echo "It seems that the host's ip is not suitable for a KVM host!! Check first."
	exit 1
fi

	
VM_CONFIG() {
	j=$i
	DOMAIN=domain-0"$j"
	virsh shutdown $DOMAIN	>/dev/null 2>&1

	let D_GUEST_IPADDR=$D_KVMHOST_IP+$j
	GUEST_IPADDR=$ABC_KVMHOST_IP$D_GUEST_IPADDR
	GUEST_IPADDR_F=`echo ${GUEST_IPADDR//./-}`
	GUEST_GW=$KVMHOST_GW
	NEW_HOST_ALIAS=kvmguest-$GUEST_IPADDR_F-$HOST_AREA
	NEW_HOSTNAME=$NEW_HOST_ALIAS".wacai.com"
	echo -e "DEVICE=eth0\nBOOTPROTO=static\nONBOOT=yes\nIPADDR=$GUEST_IPADDR\nNETMASK=255.255.255.0\nGATEWAY=$GUEST_GW\nNM_CONTROLLED=no" >/tmp/ifcfg-eth0 
	echo -e "NETWORKING=yes\nHOSTNAME=$NEW_HOSTNAME" > /tmp/network
	echo -e "127.0.0.1\tlocalhost\n$GUEST_IPADDR\t$NEW_HOSTNAME\t$NEW_HOST_ALIAS" >/tmp/hosts	

	guestfish -d $DOMAIN -i -w rm /etc/udev/rules.d/70-persistent-net.rules
	guestfish -d $DOMAIN -i -w rm /etc/salt/minion_id
	virt-copy-in -d $DOMAIN  /tmp/ifcfg-eth0  /etc/sysconfig/network-scripts/ 
	virt-copy-in -d $DOMAIN  /tmp/network /etc/sysconfig/
	virt-copy-in -d $DOMAIN  /tmp/hosts /etc/resolv.conf /etc/
	#virt-edit -d $DOMAIN  /etc/sysconfig/network -e "s/*.HOSTNAME.*/HOSTNAME=$NEW_HOSTNAME/"
	
	echo "$DOMAIN config has been copied"

}


usage() {
	N=$(basename "$0")
	echo -e "Usage: $N {number:how many kvmguest you want to setup }\nExample: $N 9\n\t$N 7" >&2
	exit 1
}

if [ $# -ne 1  ]
then
	usage
	exit 1
fi


for ((i=1;i<=${1};i++))
do
	VM_CONFIG $i
done

rm -rf /etc/libvirt/qemu/networks/autostart/*
service libvirtd restart 
