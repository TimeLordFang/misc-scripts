#########################################################################
# File Name: ipmac.sh
# Created Time: Mon 07 Mar 2016 10:49:00 PM EST
#########################################################################
#!/bin/bash


IP2MAC() {
	MAC_HEAD="52:51"
	IP_A=`echo $IP_ADDR|cut -d. -f1`
	IP_B=`echo $IP_ADDR|cut -d. -f2`
	IP_C=`echo $IP_ADDR|cut -d. -f3`
	IP_D=`echo $IP_ADDR|cut -d. -f4`

	MAC_ADDR=$MAC_HEAD`printf ":%02x" $IP_A $IP_B $IP_C $IP_D`
	echo $MAC_ADDR
}

MAC2IP() {
	let IP_A=0x`echo $MAC_ADDR | cut -d: -f 3`
	let IP_B=0x`echo $MAC_ADDR | cut -d: -f 4`
	let IP_C=0x`echo $MAC_ADDR | cut -d: -f 5`
	let IP_D=0x`echo $MAC_ADDR | cut -d: -f 6`
	
	IP_ADDR="$IP_A.$IP_B.$IP_C.$IP_D"
	echo $IP_ADDR	
}

if [ ${#1} = 17 ]
then 
	MAC_ADDR=$1
	MAC2IP
else
	IP_ADDR=$1
	IP2MAC
fi


