#!/usr/bin/bash


# get_device_name() {
#     local ip=$1
#     local mac_address=$(arp -n $ip | awk '/ether/ {print $3}')

#     if [ -n "$mac_address" ]; then
#         local device_name=$(arp -a | grep $mac_address | awk '{print $1}')
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
