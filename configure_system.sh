#!/bin/bash

#set hostname to pc200386136
sudo hostnamectl set-hostname pc200386136

#Set timezone to Toronto
sudo timedatectl set-timezone America/Toronto

#update & sync date and time using NTP & sent outputs to null
sudo apt update -y > /dev/null 2>&1 
sudo ntpdate pool.ntp.org > /dev/null 2>&1

#verify changes
echo "the hostname is $(hostnamectl --static)"
echo "The date is $(date)"

echo "Configuration Complete!"
