#!/bin/bash

#script for checking system status

#Display cpu activity
echo "CPU Activity: $(uptime)"

#Display free memory 
echo "Free Memory: $(free -h | grep Mem | awk '{print $4}')"

#Display free disk space
echo "Free Disk Space: $(df -h / |grep / | awk '{print $4}')"
