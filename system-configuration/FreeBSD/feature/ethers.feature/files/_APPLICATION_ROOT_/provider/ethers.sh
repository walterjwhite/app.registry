_ethers() {
	rm -f /etc/ethers
	for _client_device_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f); do
		. $_client_device_file
		_mac
		printf '%s %s\n' "$_MAC" "$IP" >>/etc/ethers
		unset IP FQDN HOSTNAME DOMAIN
	done
}
