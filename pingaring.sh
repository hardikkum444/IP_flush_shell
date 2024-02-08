#!/usr/bin/bash


 get_device_name() {
    local ip=$1
    local mac_address=$(arp -n $ip | awk '/ether/ {print $3}')

    if [ -n "$mac_address" ]; then
        local device_name=$(arp -a | grep $mac_address | awk '{print $1}')
#         if [ -n "$device_name" ]; then
#             echo "Device name for $ip: $device_name"
#         else
#             echo "Unable to get device name for $ip"
#         fi
#     else
#         echo "Unable to get device name for $ip"
#     fi
# }

# Iterate through IP addresses from 192.168.225.1 to 192.168.225.254
for ip in {1..254}
do
    current_ip="192.168.225.$ip"

    
    ping -c 1 $current_ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &

    
    get_device_name $current_ip

    echo "------------------"
done








#!/bin/bash

# Function to get the device name associated with an IP address
get_device_name() {
    local ip=$1
    local mac_address=$(arp -n $ip | awk '/ether/ {print $3}')

    if [ -n "$mac_address" ]; then
        local device_name=$(arp -a | grep $mac_address | awk '{print $1}')
        if [ -n "$device_name" ]; then
            echo "Device name for $ip: $device_name"
        else
            echo "Unable to get device name for $ip"
        fi
    else
        echo "Unable to get device name for $ip"
    fi
}

# Determine the network address and subnet mask
network_info=$(ip route | awk '/default/ {print $3}')
network_address=$(echo $network_info | cut -d '/' -f 1)
subnet_mask=$(echo $network_info | cut -d '/' -f 2)

# Calculate the network range
IFS='.' read -r -a octets <<< "$network_address"
IFS='.' read -r -a mask_octets <<< "$subnet_mask"
network_range="${octets[0]}.${octets[1]}.${octets[2]}.0/$(($mask_octets[0] + $mask_octets[1] + $mask_octets[2] + $mask_octets[3]))"

echo "Scanning network range: $network_range"

# Iterate through IP addresses in the network range
for ip in $(nmap -sL $network_range | grep 'Nmap scan report for' | awk '{print $NF}')
do
    # Skip the current IP if it's the local machine's IP
    if [ "$ip" != "$network_address" ]; then
        # Ping the IP address to check if it's reachable
        ping -c 1 $ip > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            # Extract the MAC address from the ARP table
            mac_address=$(arp -n $ip | awk '/ether/ {print $3}')
            if [ -n "$mac_address" ]; then
                # Call the function to get the device name
                get_device_name $ip
            else
                echo "Unable to retrieve MAC address for $ip"
            fi
        else
            echo "Host $ip is unreachable"
        fi
    fi
    echo "------------------"
done