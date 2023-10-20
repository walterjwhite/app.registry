_pf() {
	FIREWALL=/usr/local/etc/walterjwhite/firewall
	macro=$FIREWALL/macros/hosts
	rm -f $macro
	if [ ! -e $FIREWALL/macros ]; then
		_warn "$FIREWALL/macros does not exist, aborting"
		return
	fi
	_build_zones
	_TARGET=$FIREWALL/rules.pf
	rm -f $_TARGET
	_concat policies
	_concat macros
	_concat rules
	_concat queue
}
_build_zone() {
	_ZONE_HOSTS=""
	for _client_device_file in $(find $zone -type f | grep -v device$); do
		. $_client_device_file
		_ZONE_HOSTS="$_ZONE_HOSTS $IP"
	done
	printf 'zone_%s="%s"\n' "$_ZONE_NAME" "$_ZONE_HOSTS" >>$macro
}
_build_zones() {
	for zone in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -maxdepth 1 -type d ! -name 'devices'); do
		_ZONE_NAME=$(basename $zone)
		_build_zone
	done
}
_write_anchor() {
	if [ -z "$1" ]; then
		_warn "Anchor filename is empty."
		return
	fi
	#printf '# %s\n' "$(basename $1)" >>$_TARGET
	#$_CONF_INSTALL_GNU_GREP -Pv "(^#|^$)" $1 >>$_TARGET
	printf 'include "%s"\n' "$1" >>$_TARGET
}
_concat() {
	local _type=$1
	printf '###\n' >>$_TARGET
	printf '# %s\n' "$_type" >>$_TARGET
	if [ -e $FIREWALL/$_type ]; then
		for _MATCHING_FILE in $(find $FIREWALL/$_type -type f ! -name 'rules.pf' | sort); do
			_write_anchor $_MATCHING_FILE
		done
	fi
	printf '\n' >>$_TARGET
}
