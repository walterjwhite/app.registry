_PLUGIN_CONFIGURATION_PATH=~/.ssh
_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
_PLUGIN_EXCLUDE="socket"
_configure_ssh_clear() {
	_warn "Not clearing ssh"
}
_configure_ssh_restore_pre() {
	if [ -n "$_CONF_FREEBSD_INSTALLER_HOSTNAME" ] && [ -e ~/.ssh ]; then
		_warn "_CONF_FREEBSD_INSTALLER_HOSTNAME was set, backing up ssh config"
		_SSH_CONFIG_TEMPFILE=$(mktemp -d)
		mv ~/.ssh $_SSH_CONFIG_TEMPFILE
	fi
}
_configure_ssh_restore_post() {
	mkdir -p ~/.ssh/socket
	find ~/.ssh -type d -exec chmod 700 {} +
	find ~/.ssh -type f -exec chmod 600 {} +
	if [ -n "$_SSH_CONFIG_TEMPFILE" ]; then
		_warn "_SSH_CONFIG_TEMPFILE was set, restoring ssh/config"
		mv ~/.ssh ~/.ssh.restore
		mv $_SSH_CONFIG_TEMPFILE/.ssh ~/.ssh
		chmod 600 ~/.ssh/config
	fi
}
