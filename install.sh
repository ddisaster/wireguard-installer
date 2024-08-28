#!/bin/bash

# BASICS

ls /root &> /dev/null

if [ "$?" != "0" ]; then
	echo "Run this script with root privileges"
	exit 1
fi

function error {
	echo "error"
	exit 1
}

if [[ -e /etc/wireguard/config ]]; then
	read -p "Wireguard seams already to be installed! Just update scrpts? [y|n] " -n 1 update
	echo
fi

if [ "${update}" != "y" ]; then
	# SET VARS

	while true; do
		clear
		read -p "Customer Name [comse]: " cust_name
		if [ "${cust_name}" = "" ]; then cust_name="comse"; fi
		read -p "Server address [comse.dyndns.org]: " server_addr
		if [ "${server_addr}" = "" ]; then server_addr="comse.dyndns.org"; fi
		read -p "Port [51820]: " port
		if [ "${port}" = "" ]; then port="51820"; fi
		read -p "Customer network [192.168.99.0/24]: " cust_network
		if [ "${cust_network}" = "" ]; then cust_network="192.168.99.0/24"; fi
		read -p "Server IP [192.168.99.206/24]: " server_ip
		if [ "${server_ip}" = "" ]; then server_ip="192.168.99.206/24"; fi
		read -p "Customer vpn network [10.99.99.0]: " vpn_network
		if [ "${vpn_network}" = "" ]; then vpn_network="10.99.99.0"; fi
		read -p "All Informations correct? [y|n] " -n 1 finished
		echo
		if [ "${finished}" = "y" ]; then
			break
		fi
	done

	iface="$(ip route get 8.8.8.8 | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}')"
	gateway="$(ip route | grep default | awk '{print $3}')"

	linux_user="$(ls /home | head -n 1)"

	rm -rf /etc/wireguard/*

	echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
	printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable

	mv /etc/network/interfaces /etc/network/interfaces.backup
	grep -v ${iface} /etc/network/interfaces.backup > /etc/network/interfaces
	echo "allow-hotplug ${iface}" >> /etc/network/interfaces
	echo "iface ${iface} inet static" >> /etc/network/interfaces
	echo "   address ${server_ip}" >> /etc/network/interfaces
	echo "   gateway ${gateway}" >> /etc/network/interfaces
fi

apt update || error
apt upgrade -y || error
apt install -y wireguard git vim iptables || error
tmpfldr="$(mktemp -d)"
git clone https://github.com/ddisaster/wireguard-installer.git ${tmpfldr}

if [ "${update}" != "y" ]; then
	private="$(wg genkey)"
	echo ${private} > /etc/wireguard/wg-private.key
	public="$(echo ${private} | wg pubkey)"
	echo ${public} > /etc/wireguard/wg-public.key

	cat ${tmpfldr}/wg0-server.example.conf | \
		sed -e "s/ADDRESS/$(echo ${vpn_network} | cut -d '.' -f -3).2/" | \
		sed -e "s/PORT/${port}/" | \
		sed -e "s/IFACE/${iface}/" | \
		sed -e "s|PRIVKEY|${private}|" \
		> /etc/wireguard/wg0.conf

	echo "2" > /etc/wireguard/last-ip.txt

	echo "#!/bin/bash" > /etc/wireguard/config
	echo "vpn_network=\"${vpn_network}\"" >> /etc/wireguard/config
	echo "cust_network=\"${cust_network}\"" >> /etc/wireguard/config
	echo "server_addr=\"${server_addr}\"" >> /etc/wireguard/config
	echo "server_public=\"${public}\"" >> /etc/wireguard/config
	echo "port=\"${port}\"" >> /etc/wireguard/config
	echo "linux_user=\"${linux_user}\"" >> /etc/wireguard/config
	echo "cust_name=\"${cust_name}\"" >> /etc/wireguard/config
	mkdir /etc/wireguard/clients
	cp ${tmpfldr}/wg0-client.example.conf /etc/wireguard/wg0-client.example.conf
fi

function copy_script () {
    cp ${tmpfldr}/${1} /usr/bin/${1}
    chmod u+x /usr/bin/${1}
}

copy_script wg-add-client
copy_script wg-remove-client
copy_script wg-list-clients
copy_script wg-fix-removed_users

systemctl enable wg-quick@wg0.service
systemctl reboot
