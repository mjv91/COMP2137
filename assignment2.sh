#!/bin/bash

# ---------------------------------------------------
# COMP2137 Assignment 2
# Author: Micheal Verconich
# This script configures server1 for the assignment.
# It sets up apache2 and squid, adds users with SSH keys,
# and makes sure 'frodo' has sudo privileges and SSH access.
# ---------------------------------------------------

# ----------- Define Variables -----------
STATIC_IP="192.168.16.21/24"
NETPLAN_FILE="/etc/netplan/10-lxc.yaml"
HOSTS_FILE="/etc/hosts"
FRODO_KEY="ssh-ed25519 AAAAC3Nzac1LZDI1NTE5AAAAIG4rT3vTt990x5kndS4HmgTrKBT8SKzh8F example@example"

# Packages we want to install
NEEDED_PACKAGE_1="apache2"
NEEDED_PACKAGE_2="squid"

# User list
USER1="frodo"
USER2="perrier"
USER3="cindy"
USER4="tiger"
USER5="yoda"

# ----------- Check for Root -----------
# This part ensures the script is being run with root permissions
if [ "$(id -u)" != "0" ]; then
  echo "Please run this script as root."
  exit 1
fi

echo "Starting system configuration..."
echo "----------------------------------"

# ----------- Network Setup Note -----------
# DO NOT automate YAML file edits with sed; it breaks indentation.
# We'll just notify the user to manually ensure it's correct.

echo "NOTE: Ensure the static IP $STATIC_IP is manually set in $NETPLAN_FILE"
echo "If you've updated it, run: sudo netplan apply"
echo

# ----------- Hosts File Update -----------
# Add a line for server1 if it’s not already in /etc/hosts
grep -q "server1" "$HOSTS_FILE"
if [ $? -ne 0 ]; then
  echo "192.168.16.21 server1" >> "$HOSTS_FILE"
  echo "server1 added to $HOSTS_FILE"
else
  echo "server1 already exists in $HOSTS_FILE"
fi

# ----------- Install Packages -----------
# This checks and installs packages one by one
if ! dpkg -l | grep -q "$NEEDED_PACKAGE_1"; then
  echo "Installing $NEEDED_PACKAGE_1..."
  apt update -y
  apt install -y "$NEEDED_PACKAGE_1"
else
  echo "$NEEDED_PACKAGE_1 is already installed."
fi

if ! dpkg -l | grep -q "$NEEDED_PACKAGE_2"; then
  echo "Installing $NEEDED_PACKAGE_2..."
  apt install -y "$NEEDED_PACKAGE_2"
else
  echo "$NEEDED_PACKAGE_2 is already installed."
fi

# ----------- Create Users -----------
# This creates users if they don't already exist
for USER in $USER1 $USER2 $USER3 $USER4 $USER5; do
  if id "$USER" &>/dev/null; then
    echo "User $USER already exists."
  else
    useradd -m -s /bin/bash "$USER"
    echo "User $USER created."
  fi

  # Set default password (not secure in real world)
  echo "$USER:changeme" | chpasswd

  # Force password change on next login
  chage -d 0 "$USER"
done

# ----------- SSH Key for Frodo -----------
# Create .ssh directory and authorized_keys file
FRODO_HOME="/home/$USER1"
FRODO_SSH="$FRODO_HOME/.ssh"

if [ ! -d "$FRODO_SSH" ]; then
  mkdir -p "$FRODO_SSH"
  chown "$USER1:$USER1" "$FRODO_SSH"
  chmod 700 "$FRODO_SSH"
  echo "SSH folder created for $USER1"
fi

echo "$FRODO_KEY" > "$FRODO_SSH/authorized_keys"
chown "$USER1:$USER1" "$FRODO_SSH/authorized_keys"
chmod 600 "$FRODO_SSH/authorized_keys"
echo "SSH key added for $USER1"

# ----------- Add Frodo to Sudo -----------
usermod -aG sudo "$USER1"
echo "$USER1 has been added to sudo group."

# ----------- Done! -----------
echo "Configuration complete!"

