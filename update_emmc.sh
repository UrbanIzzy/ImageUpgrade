#!/bin/bash

{
# flash boot bin to qspi memory
echo "flashing BOOT.BIN to QSPI memoty.."
pwd
flashcp new_upgrade_sources/bootfiles/BOOT.BIN /dev/mtd0
if [ $? -eq 0 ]
then
	echo "flashing BOOT.BIN to QSPI memoty - DONE" 
else
	echo "flashing to QSPI memory - FAIL"
fi

# duplicat image to emmc memory 
echo "copy image to internal emmc memory.."
dd if=new_upgrade_sources/maps_emmc.img of=/dev/mmcblk1 bs=4M
if [ $? -eq 0 ]
then 
	echo "copy image to internal emmc memory- DONE"
else
	echo "copy image - FAILED"
fi
sync

# configure new ip
mount /dev/mmcblk1p2 /mnt

cat << EOF >  /mnt/etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
# source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback
#allow hotplug eth0

auto eth0
#iface eth0 inet dhcp
iface eth0 inet static
address $1
netmask 255.255.0.0
gateway 172.16.0.200
dns-nameservers 8.8.8.8
EOF

sync
umount /mnt
} > log.log 2>&1





