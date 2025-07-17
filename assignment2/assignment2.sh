#!/bin/bash

# COMP2137 Assignment 2
# Micheal Verconich
# This script configures server1 for the assignment requirements.
# It sets a static IP, installs apache2 and squid, creates users with SSH,
# and gives frodo sudo and a public key.

# Define values that will be used
STATIC_IP="192.168.16.21/24"
NETPLAN_FILE="/etc/netplan/10-lxc.yaml"
HOSTS_FILE="/etc/hosts"

# Public key that must be added to frodo
FRODO_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

# Packages that need to be installed
NEEDED_PACKAGE_1="apache2"
NEEDED_PACKAGE_2="squid"

# Users to create
USER1="frodo"
USER2="aubrey"
USER3="captain"
USER4="snibbles"
USER5="brownie"
USER6="scooter"
USER7="sandy"
USER8="perrier"
USER9="cindy"
USER10="tiger"
USER11="yoda"

# Make sure script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "Please run this script as root."
    exit 1
fi

echo "Starting setup..."

# ----------- Network Setup ------------
# Check if the static IP is already in the netplan file
grep "$STATIC_IP" "$NETPLAN_FILE" > /dev/null
if [ $? -ne 0 ]; then
    sed -i "/addresses:/c\        addresses: [$STATIC_IP]" "$NETPLAN_FILE"
    echo "Netplan updated with $STATIC_IP"
    netplan apply
else
    echo "Static IP already set in netplan."
fi

# Update /etc/hosts for server1 entry
grep "server1" "$HOSTS_FILE" > /dev/null
if [ $? -eq 0 ]; then
    sed -i "/server1/ s/.*/192.168.16.21 server1/" "$HOSTS_FILE"
    echo "/etc/hosts entry updated for server1."
else
    echo "192.168.16.21 server1" >> "$HOSTS_FILE"
    echo "server1 added to /etc/hosts."
fi

# ----------- Software Installation ------------
# Install apache2 if not already there
dpkg -l | grep "$NEEDED_PACKAGE_1" > /dev/null
if [ $? -ne 0 ]; then
    apt update -qq
    apt install -y "$NEEDED_PACKAGE_1"
    echo "apache2 installed."
else
    echo "apache2 already installed."
fi

# Install squid if not already there
dpkg -l | grep "$NEEDED_PACKAGE_2" > /dev/null
if [ $? -ne 0 ]; then
    apt install -y "$NEEDED_PACKAGE_2"
    echo "squid installed."
else
    echo "squid already installed."
fi

# ----------- User Account Creation ------------
# Create a function so we don’t repeat code for each user
create_user_and_ssh() {
    USERNAME=$1
    if id "$USERNAME" > /dev/null 2>&1; then
        echo "User $USERNAME already exists."
    else
        useradd -m -s /bin/bash "$USERNAME"
        echo "User $USERNAME created."
    fi

    SSH_DIR="/home/$USERNAME/.ssh"
    mkdir -p "$SSH_DIR"
    chown "$USERNAME:$USERNAME" "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    if [ ! -f "$SSH_DIR/id_rsa.pub" ]; then
        sudo -u "$USERNAME" ssh-keygen -t rsa -N "" -f "$SSH_DIR/id_rsa"
        echo "RSA key generated for $USERNAME"
    fi

    if [ ! -f "$SSH_DIR/id_ed25519.pub" ]; then
        sudo -u "$USERNAME" ssh-keygen -t ed25519 -N "" -f "$SSH_DIR/id_ed25519"
        echo "ED25519 key generated for $USERNAME"
    fi

    cat "$SSH_DIR/id_rsa.pub" "$SSH_DIR/id_ed25519.pub" > "$SSH_DIR/authorized_keys"

    if [ "$USERNAME" = "frodo" ]; then
        echo "$FRODO_KEY" >> "$SSH_DIR/authorized_keys"
        usermod -aG sudo frodo
        echo "Added public key and sudo access for frodo."
    fi

    chown "$USERNAME:$USERNAME" "$SSH_DIR/authorized_keys"
    chmod 600 "$SSH_DIR/authorized_keys"
}

# Now call the function for each user
create_user_and_ssh "$USER1"
create_user_and_ssh "$USER2"
create_user_and_ssh "$USER3"
create_user_and_ssh "$USER4"
create_user_and_ssh "$USER5"
create_user_and_ssh "$USER6"
create_user_and_ssh "$USER7"
create_user_and_ssh "$USER8"
create_user_and_ssh "$USER9"
create_user_and_ssh "$USER10"
create_user_and_ssh "$USER11"

# Final message
echo "All tasks completed. Script finished."
