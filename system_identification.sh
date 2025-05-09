#!/bin/bash

#Script for checking system info

#Display hostname
echo "Hostname: $(hostname)"

#Display IP address (ens33)
echo "IP Address: $(ip a show ens33 |grep inet | grep -v inet6 | awk '{print $2}' | cut -d/ -f1)"

#Display default gateway IP
echo "Gateway IP: $(ip route | grep default | awk '{print $3}')"
