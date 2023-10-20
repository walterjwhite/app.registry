_isc_dhcpd() {
	cd /tmp
	if [ ! -e /usr/local/etc/dhcpd.conf ]; then
		return 0
	fi
	_DHCPD_INCLUDE=/usr/local/etc/dhcpd/include.conf
	rm -f $_DHCPD_INCLUDE
	mkdir -p $(dirname $_DHCPD_INCLUDE)
	_isc_dhcpd_write_header
	_isc_dhcpd_build_zones
}
_isc_dhcpd_write_header() {
	printf 'subnet %s netmask %s {\n' "$subnet" "$netmask" >>$_DHCPD_INCLUDE
	printf '  option broadcast-address %s;\n' "$broadcast" >>$_DHCPD_INCLUDE
	printf '  option routers %s;\n' "$routers" >>$_DHCPD_INCLUDE
	printf '  option domain-name-servers %s;\n' "$routers" >>$_DHCPD_INCLUDE
	printf '  option ntp-servers %s;\n' "$routers" >>$_DHCPD_INCLUDE
	printf '}\n\n' >>$_DHCPD_INCLUDE
	printf 'local-address %s;\n\n' "$routers" >>$_DHCPD_INCLUDE
}
_isc_dhcpd_build_zones() {
	local zone_path
	for zone_path in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -maxdepth 1 -type d ! -name 'devices'); do
		_isc_dhcpd_build_host $zone_path
	done
}
_isc_dhcpd_build_host() {
	local _client_device_file
	for _client_device_file in $(find $1 -type f); do
		. $_client_device_file
		_mac
		printf '  # %s\n' "$(basename $(dirname $_client_device_file))" >>$_DHCPD_INCLUDE
		printf '  host %s {\n' "$FQDN" >>$_DHCPD_INCLUDE
		printf '    hardware ethernet %s;\n' "$_MAC" >>$_DHCPD_INCLUDE
		printf '    fixed-address %s;\n' "$IP" >>$_DHCPD_INCLUDE
		printf '    option host-name %s;\n' "$HOSTNAME" >>$_DHCPD_INCLUDE
		printf '    option domain-name "%s";\n' "$DOMAIN" >>$_DHCPD_INCLUDE
		printf '  }\n' >>$_DHCPD_INCLUDE
		#unset _MANUFACTURER _FORM_FACTOR _OWNER instance _ZONE _TYPE _DOMAIN_SUFFIX
	done
}
