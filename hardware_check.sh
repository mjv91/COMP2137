#!/bin/bash

#check first if user has root privilages, if user doesn't exit .sh as 
#commands need to be ran with sudo

# check for root privileges
if [ "$(id -u)" -ne 0 ]; then
 echo "This script must be ran as a root or with sudo."
 exit 1
fi

# Network interface names
echo "Network Interface Names:"
ip link show | grep -oP '^\d+: \K\w+'| grep -w "ens33" #Lists all network interface ^-start of line
#\d+ matches one or more digits \K\w+ ignore everything matched before and \K and\w+ lists interface only 
echo ""

#Processor Information
echo "Processor Info:"
cat /proc/cpuinfo | grep -m 1 "model name" #Displays the processor models name
cat /proc/cpuinfo | grep "cpu cores" | uniq #Displays the number of cores
cat /proc/cpuinfo | grep "cpu MHz" | uniq #Displays the speed of the processor
echo ""

#Memory Size
echo "Memory Information:"
free -h | grep Mem  #Displays memory size in readable format
echo ""

#Dis Drives"
echo "Disk Drive Information:"
lsblk -o NAME,SIZE,MODEL | grep -v "loop"  #Displays the device names,sizes,and models of disk drives
echo ""

#Video Card
echo "Video Card Information:"
lspci | grep VGA #Displays the video card model name 
echo ""

echo "All hardware information gathered!"

