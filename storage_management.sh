#!/bin/bash

# identify mounted local disk filesystems 
echo " Mounted Locak Disk Filesystems:"
df -hT | grep -v "^tmpfs" #shows mounted files systems exculding tmpfs
echo ""

# Identify Free space and number of files in the home directory
echo "Free space in the filesystem holding your home directory"
df -h $HOME | awk 'NR==2 {print $4}' #show th available free space in /home directory
echo ""

# Identify Space Used and number of Files in the Home Directory
echo "Space Used and File Count in My Home  Directory:"
du -sh $HOME  # show the total space used in /home
find $HOME -type f | awk 'END {print NR}' 
echo ""

echo "Storage Management Information Complete"
