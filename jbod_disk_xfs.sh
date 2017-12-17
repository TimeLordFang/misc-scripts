#########################################################################
# File Name: jbod_disk_xfs.sh
# Created Time: Wed 13 Jul 2016 02:48:10 PM CST
#########################################################################
#!/bin/bash

modprobe xfs
cp /etc/fstab{,.bak}

parted_device() {
	device_path=$1
	parted $device_path  <<EOF
mklabel gpt  
yes
mkpart primary 0 -1  
ignore  
quit  
EOF
echo -e "\n$device_path was parted!"
}

mkfs_xfs() {

	partition_path=$1
	mount_dir=/data$2
    mkdir $mount_dir
	mkfs.xfs -f -d agcount=64 -l size=128m -L data$2 $partition_path
	if [ "$?" = "0"  ];then
        echo -e "\n$partition_path  was Formated using xfs."    
	fi
	partition_uuid=`blkid|grep $partition_path |awk -F\" '{print $4}'`
	echo -e "UUID=$partition_uuid\t$mount_dir\txfs    defaults,noatime        1 2"  >>/etc/fstab

}


parted_device	/dev/sdb
parted_device	/dev/sdc
parted_device	/dev/sdd
parted_device	/dev/sde
parted_device	/dev/sdf
parted_device	/dev/sdg
parted_device	/dev/sdh
parted_device	/dev/sdi

mkfs_xfs /dev/sdb1 1
mkfs_xfs /dev/sdc1 2
mkfs_xfs /dev/sdd1 3
mkfs_xfs /dev/sde1 4
mkfs_xfs /dev/sdf1 5
mkfs_xfs /dev/sdg1 6
mkfs_xfs /dev/sdh1 7
mkfs_xfs /dev/sdi1 8

mount -a 
