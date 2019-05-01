#!/bin/bash

#Mount points according to the Lun numbers of the vhds : eg : LUN0 will be mounted on /usr/sap, LUN1 will be mounted on /hana/data
#mountpointLUN_array=('/usr/sap' '/hana/shared' '/backup' '/hana/data' '/hana/log' ) 
#mountpointLUN_array=('/usr/sap' '/usr/sap/S4P' '/usr/sap/S4P/ASCS00' '/usr/sap/S4P/ERS10' )
#use none for lun LV that span the same vg
#lvm size input scenario
#mountpointLUN_array=('/usr/sap:lun0,lun1:VG00,LV00' '/usr/sap/S4P:lun2,lun3,lun4:VG01,LV01' '/usr/sap/S4P/ASCS00:lun5,lun6,lun7:VG02,LV02' '/usr/sap/S4P/ERS10:lun8,lun9:VG03,LV03' )
mountpointLUN_array=('/usr/sap' '/usr/sap/S4P' )

#mountpointLUN_array=('/usr/sap:lun0,lun1:VG00,LV00' '/usr/sap/S4P:lun2,lun3:VG01,LV01' )

#Select the file system type
fs_type=xfs

#Logging Changed the install logs to /tmp
mkdir -p /tmp/post-install
exec   1>>/tmp/post-install/misc.log 2>&1

systemos_prep() {

cp /etc/resolv.conf /etc/resolv.conf_$(date +%Y%m%d_%H%M%S)
#sed -i 's/reddog.microsoft.com/provingground.net/' /etc/resolv.conf
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0_$(date +%Y%m%d_%H%M%S)
echo 'SEARCH="provingground.net"' >> /etc/sysconfig/network-scripts/ifcfg-eth0

timedatectl set-timezone America/Los_Angeles
#log restarting crond and rsyslog to fix time zone 
#systemctl restart crond.service
#systemctl restart rsyslog
#restart network to update dhcp



#Stopping firewall, instead might want to open the right ports
systemctl stop firewalld

#mounting nfs
mkdir /sapmedia
#sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:export/media /sapmedia
echo "pg-nfs01.provingground.net:/export/media  /sapmedia  nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab
#mount -a

#install packages for SAP
yum -y install bzip2 iproute iputils mktemp patch redhat-lsb compat-sap-c++-6 libtool-ltdl nfs-utils nfs-utils-lib

#install package uuidd to resolve the login error resolved with /sick 
yum -y install uuidd

#install and configure X11
yum -y install xorg-x11-xauth xorg-x11-fonts-* xorg-x11-font-utils xorg-x11-fonts-Type1
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_$(date +%Y%m%d_%H%M%S)
sed -i -e  's/^ *X11Forwarding \+no/X11Forwarding yes/'   /etc/ssh/sshd_config


systemctl restart network

}

HANA_LOG_FILE=/tmp/post-install/fsformatnmount.log
log() {
#changing from tee to > as we don't want the output to be printed to both stdout and the file
    echo `date` $*  >>  $HANA_LOG_FILE 2>&1
}


#Function to create partition the disk, create file system and entry in fstab
fn_disk_partition () {

log  "Partitioning $1"
parted $1 unit $4
parted $1 mklabel gpt
parted $1 mkpart primary 0% 100%
parted $1 set 1 lvm on
sleep 2
log "Creating Parition for ${1}1"

}

#modify $1 for parition in uuid=`blkid -s UUID -o value ${1}1
fn_mkfs_fstab () {
mkfs'.'$2 ${1}
if [ $? == 0 ]
then
	uuid=`blkid -s UUID -o value ${1}`
	if [ ! -z $uuid ]
	then
		log "Appending the /etc/fstab for ${1} on $2"
		echo "UUID=\"$uuid\" $3 $2 defaults,nofail     0 2" >> /etc/fstab
#04/06 Comment - Creating directory and mounting to prevent failure when creating directories under /usr/sap which itself is a mount point
		mkdir -p $3
		mount -U $uuid $3 -t $2 -o defaults,nofail
	else
		fn_exit "uuid for ${1} is empty"
	fi
else
	fn_exit "mkfs.$2 ${1} command failed"
fi

}


fn_exit () {
log  "$1"
exit 22
}

#OS prep for SAP install
systemos_prep

#printing the disk sizes and lun numbers of the scsi devices
lsblk -S -o name,hctl,size,type

disk_array=($(ls -l /dev/disk/azure/* | grep lun | awk -F\/  '{ print $NF }'))

if [ ${#mountpointLUN_array[*]} -gt 0  ]
then
	if [ ${#disk_array[*]} -gt 0 ]
	then
		for ((i=0; i<${#mountpointLUN_array[*]}; i++))
		do

			
			mount_point=`echo ${mountpointLUN_array[$i]} | awk -F: '{print $1}'`
			lun_nums=`echo ${mountpointLUN_array[$i]} | awk -F: '{print $2}'`
			total_lun=`echo ${mountpointLUN_array[0]} | awk -F: '{print $2}' | awk '{print NF}' FS=,`
	
			vg_name=`echo ${mountpointLUN_array[$i]} | awk -F: '{print $3}' | awk -F',' '{print $1}'`
			lv_name=`echo ${mountpointLUN_array[$i]} | awk -F: '{print $3}' | awk -F',' '{print $2}'`
			
			if [[ -z $lun_nums || -z $vg_name || -z $lv_name ]]
			then
#			fn_exit 'Empty variable $lun_nums $vg_name  $lv_name'
			
				disksize=`lsblk -no SIZE /dev/${disk_array[$i]}`
				no_paritions=`lsblk | grep ${disk_array[$i]} | wc -l`
				if [ $no_paritions == 1 ]
				then
				disk_unit=`echo $disksize | tr -d '0-9'`
					if [ $disk_unit == "T" ]
					then
						#remove $fs_type
						fn_disk_partition /dev/${disk_array[$i]}  ${mountpointLUN_array[$i]} $fs_type ${disk_unit}B
						fn_mkfs_fstab  /dev/${disk_array[$i]}1 $fs_type ${mountpointLUN_array[$i]}
						
					elif [ $disk_unit == "G" ]
					then
						#remove $fs_type
						fn_disk_partition /dev/${disk_array[$i]}  ${mountpointLUN_array[$i]} $fs_type ${disk_unit}B
						fn_mkfs_fstab /dev/${disk_array[$i]}1 $fs_type ${mountpointLUN_array[$i]}
					else
						fn_exit "Error in disk size"
					fi
				else
				fn_exit "Error : The device /dev/${disk_array[$i]} has partitions"
				fi
			else
			
			lun_array=()
	
			for ((j=0; j<$total_lun ; j++))
			do
	
			k=`expr $j + 1`
		
			lun_array[$j]=`echo ${mountpointLUN_array[i]} | awk -F: '{print $2}' | awk -v it="$k" '{print $it}' FS=,`
			lun_array[$j]=`echo /dev/disk/azure/scsi1/${lun_array[$j]}`
		
			if [[ -L ${lun_array[$j]} ]]
			then	
				echo sym link exists
		
			else 
				fn_exit
			
			fi
				
			done

			echo ${lun_array[*]}
			pvcreate ${lun_array[*]}
			vgcreate $vg_name ${lun_array[*]}
			lvcreate --extents 100%FREE --stripes $total_lun --name $lv_name $vg_name
			fn_mkfs_fstab /dev/$vg_name/$lv_name $fs_type $mount_point
			
			fi
		done

	else
		fn_exit "Empty array disk_array! No storage rules present"
	fi
else
	fn_exit "There are no mountpoints defined in the array mountpointLUN_array"
fi