_hostname() {
	printf 'hostname=%s\n' "$_CONF_FREEBSD_INSTALLER_HOSTNAME" >>/etc/rc.conf.local
}
