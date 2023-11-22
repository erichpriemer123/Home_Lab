#!/bin/bash

# Check if the required command-line utilities are installed
if ! command -v wakeonlan &> /dev/null; then
    echo "Error: wakeonlan is not installed. Please install it."
    exit 1
fi

if ! command -v ssh &> /dev/null; then
    echo "Error: ssh is not installed. Please install it."
    exit 1
fi

# Function to check if a string is a valid MAC address
is_valid_mac() {
    [[ $1 =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]
}

# Function to check if a string is a valid IP address
is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Check each octet
        local IFS='.'
        local octets=($ip)
        for octet in "${octets[@]}"; do
            if [[ ! $octet -ge 0 && ! $octet -le 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <MAC_ADDRESS> <IP_ADDRESS>"
    exit 1
fi

# MAC address of the target device
mac_address=$1
ip_address=$2

# Check if the provided MAC address is valid
if ! is_valid_mac "$mac_address"; then
    echo "Error: Invalid MAC address format."
    exit 1
fi

# Check if the provided IP address is valid
if ! is_valid_ip "$ip_address"; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Send Wake-on-LAN signal to the device
echo "Sending Wake-on-LAN signal..."
wakeonlan "$mac_address"

# Ping the device until it responds
echo "Pinging the device..."
while ! ping -c 1 -W 1 "$ip_address" &> /dev/null; do
    sleep 1
done

# Wait for 20 seconds
echo "Device is online. Waiting for full boot"
sleep 10

# Connect to the device using SSH
echo "Connecting to the device via SSH..."
ssh user@"$ip_address"