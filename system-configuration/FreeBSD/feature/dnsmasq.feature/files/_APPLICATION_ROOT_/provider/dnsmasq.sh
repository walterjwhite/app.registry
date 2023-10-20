_dnsmasq() {
	cd /tmp
	_DNSMASQ_CONF=/usr/local/etc/dnsmasq.conf
	rm -f $_DNSMASQ_CONF ${_DNSMASQ_CONF}.dhcp ${_DNSMASQ_CONF}.dns
	printf '# @see: https://wiki.archlinux.org/title/Dnsmasq\n' >${_DNSMASQ_CONF}
	printf 'conf-file=%s\n' ${_DNSMASQ_CONF}.dhcp >${_DNSMASQ_CONF}
	printf 'conf-file=%s\n' ${_DNSMASQ_CONF}.dns >${_DNSMASQ_CONF}
	_dnsmasq_dhcp
	_dnsmasq_dns
}
_dnsmasq_dhcp() {

	printf '# default gateway\n' >>${_DNSMASQ_CONF}.dhcp
	printf 'dhcp-option=3,10.30.0.1\n' >>${_DNSMASQ_CONF}.dhcp
	printf '# DNS servers\n' >>${_DNSMASQ_CONF}.dhcp
	printf 'dhcp-option=6,10.30.0.1\n\n' >>${_DNSMASQ_CONF}.dhcp
	local ending_ip=$(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f -exec grep -vl '^IP=' {} + | wc -l | awk {'print$1'})
	ending_ip=$(($ending_ip + 10 - 1))
	printf 'dhcp-range=10.30.0.%s,10.30.0.%s,%s\n' "10" "$ending_ip" "30m" >>${_DNSMASQ_CONF}.dhcp
	local _client_device_file
	for _client_device_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f); do
		. $_client_device_file
		_mac
		printf '# host: %s\n' "$FQDN" >>${_DNSMASQ_CONF}.dhcp
		printf 'dhcp-host=%s,%s\n' "$_MAC" "$IP" >>${_DNSMASQ_CONF}.dhcp
	done
}
_dnsmasq_dns() {
	printf 'interface=wired\n' >>${_DNSMASQ_CONF}.dns
	printf 'bind-interfaces\n\n' >>${_DNSMASQ_CONF}.dns

	printf 'domain=2357\n\n' >>${_DNSMASQ_CONF}.dns
	printf 'listen-address=127.0.0.1,10.30.0.1,192.1.0.2\n' >${_DNSMASQ_CONF}.dns

	printf 'cache-size=1000\n' >>${_DNSMASQ_CONF}.dns
	printf 'conf-file=/usr/local/share/dnsmasq/trust-anchors.conf\n' >>${_DNSMASQ_CONF}.dns
	printf 'dnssec\n' >>${_DNSMASQ_CONF}.dns
	printf 'domain-needed\n' >>${_DNSMASQ_CONF}.dns
	printf 'bogus-priv\n' >>${_DNSMASQ_CONF}.dns
	printf 'expand-hosts\n' >>${_DNSMASQ_CONF}.dns
	printf 'no-resolv\n' >>${_DNSMASQ_CONF}.dns
	printf 'server=1.1.1.1\n' >>${_DNSMASQ_CONF}.dns
	printf 'server=9.9.9.9\n' >>${_DNSMASQ_CONF}.dns
	printf '# dns blocklist\n' >>${_DNSMASQ_CONF}.dns
	printf 'conf-file=/usr/local/etc/walterjwhite/network/dnsmasq.block\n' >>${_DNSMASQ_CONF}.dns
}
