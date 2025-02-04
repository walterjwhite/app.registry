_get_jail_volumes() {
	grep 'path = ' /etc/jail.conf /etc/jail.conf.d -rh 2>/dev/null | awk -F'=' {'print$2'} | tr -d ' ;"' | sed -e 's/^\///' | sort -u
}
_in_jail() {
	if [ $(sysctl -n security.jail.jailed) -eq 1 ]; then
		return 0
	fi
	return 1
}
_in_jail && _FEATURE_NTP_DISABLED=1
which ntpq >/dev/null 2>&1 || _FEATURE_NTP_DISABLED=1
_ntp() {
	ntpq -pn 2>/dev/null | grep '^\*' >/dev/null 2>&1 && {
		_STATUS_MESSAGE="NTP is synchronized"
		return
	}
	_STATUS_MESSAGE="NTP is not synchronized"
}
