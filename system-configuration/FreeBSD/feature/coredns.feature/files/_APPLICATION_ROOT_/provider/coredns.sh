_coredns() {
	_COREDNS_CONFIGURATION_FILE=${_CONF_ROUTER_SETUP_COREDNS_CONFIGURATION_DIRECTORY}/Corefile
	_COREDNS_ZONES_DIRECTORY=${_CONF_ROUTER_SETUP_COREDNS_CONFIGURATION_DIRECTORY}/zones
	if [ ! -e $_CONF_ROUTER_SETUP_COREDNS_CONFIGURATION_DIRECTORY ]; then
		return 0
	fi
	_coredns_setup
	_coredns_process_zones
}
_coredns_setup() {
	rm -rf ${_COREDNS_ZONES_DIRECTORY}
	mkdir -p ${_COREDNS_ZONES_DIRECTORY}
	cp ${_COREDNS_CONFIGURATION_FILE}.template ${_COREDNS_CONFIGURATION_FILE}
}
_coredns_process_zones() {
	for _ZONE_FILE in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -maxdepth 1 -type d ! -name 'devices'); do
		_ZONE_NAME=$(basename $_ZONE_FILE)
		_coredns_write_zone
	done
}
_coredns_write_zone() {
	for _client_device_file in $(find $_ZONE_FILE -type f); do
		. $_client_device_file
		_coredns_write_domain_entry
		unset IP FQDN DOMAIN HOSTNAME
	done
}
_coredns_write_domain_entry() {
	_coredns_write_domain_header
	printf '%s IN A %s\n' "${HOSTNAME}" "${IP}" >>${_ZONE_DOMAIN_FILE}
	unset instance
}
_coredns_write_domain_header() {
	_ZONE_DOMAIN_FILE=${_COREDNS_ZONES_DIRECTORY}/${DOMAIN}
	if [ -e "${_ZONE_DOMAIN_FILE}" ]; then
		return
	fi
	printf '\$ORIGIN %s.\n' "${DOMAIN}" >>${_ZONE_DOMAIN_FILE}
	printf '@       3600 IN SOA sns.dns.icann.org. noc.dns.icann.org. (\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        2020022945 ; serial\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        7200       ; refresh (2 hours)\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        3600       ; retry (1 hour)\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        1209600    ; expire (2 weeks)\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        3600       ; minimum (1 hour)\n' >>${_ZONE_DOMAIN_FILE}
	printf '                        )\n' >>${_ZONE_DOMAIN_FILE}
	printf '3600 IN NS a.iana-servers.net.\n' >>${_ZONE_DOMAIN_FILE}
	printf '3600 IN NS b.iana-servers.net.\n' >>${_ZONE_DOMAIN_FILE}
	printf 'router IN A %s\n\n' "$routers" >>${_ZONE_DOMAIN_FILE}
	_write_coredns_domain
}
_write_coredns_domain() {
	printf '%s  { file %s\n}\n' "${DOMAIN}" "${_ZONE_DOMAIN_FILE}" >>${_COREDNS_CONFIGURATION_FILE}
}
