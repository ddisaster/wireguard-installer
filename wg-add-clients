#!/bin/bash

if [ $# -eq 0 ]
then
	echo "usage: ${0} client-name"
else
	echo "Creating client config for: $1"
	
	source /etc/wireguard/config
	mkdir -p /etc/wireguard/clients/$1
	key="$(wg keygen)"
	echo "${key}" > /etc/wireguard/clients/$1/$1.priv
	echo "${key}" | wg pubkey > /etc/wireguard/clients/$1/$1.pub
	this_ip=$(($(cat /etc/wireguard/last-ip.txt)+1))
	echo "${this_ip}" > /etc/wireguard/last-ip.txt
	ip="${cust_network}.${this_ip}"
	cat /etc/wireguard/wg0-client.example.conf | \
		sed -e "s/VPN_IP/${ip}/" | \
		sed -e "s/PRIVKEY/${key}/" | \
		sed -e "s/SERVER_PUBLIC/${server_public}/" | \
		sed -e "s#ALLOWEDIPS#${cust_network}.0/24, ${cust_network}#" | \
		sed -e "s/SERVER/${server_addr}/" \
		> clients/$1/wg0.conf
	echo "Created config!"
	
	echo "Adding peer"
	wg set wg0 peer $(cat clients/$1/$1.pub) allowed-ips $ip/32
	echo "Adding peer to hosts file"
fi
