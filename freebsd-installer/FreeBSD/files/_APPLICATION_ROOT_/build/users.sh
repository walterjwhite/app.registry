_user_bootstrap() {
	:
}
_user_install() {
	:
}
_user_uninstall() {
	:
}
_user_is_installed() {
	return 1
}
_user_is_file() {
	return 0
}
_user_enabled() {
	return 1
}
_prepare_ssh_conf() {
	$sudo mkdir -p $1/.ssh/socket
	$sudo chmod 700 $1/.ssh/socket
	printf 'StrictHostKeyChecking no\n' | $sudo tee -a $1/.ssh/config >/dev/null
	if [ -n "$_HOST_IP" ]; then
		_ssh_init_bastion_host $1
	fi
	if [ -e /tmp/HOST-SSH ]; then
		_info "Copying host ssh -> $1/.ssh"
		$sudo cp /tmp/HOST-SSH/id* $1/.ssh
	fi
	if [ "$2" != "root" ]; then
		$sudo chown -R $2:$2 $1/.ssh
	fi
}
_ssh_init_bastion_host() {
	printf 'Host host-proxy\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' Hostname %s\n' "$_HOST_IP" | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf 'Host git\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf 'Host freebsd-package-cache\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | $sudo tee -a $1/.ssh/config >/dev/null
	printf 'Host %s\n' "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | $sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | $sudo tee -a $1/.ssh/config >/dev/null
	if [ "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" != "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" ]; then
		printf 'Host %s\n' "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" | $sudo tee -a $1/.ssh/config >/dev/null
		printf ' ProxyJump host-proxy\n' | $sudo tee -a $1/.ssh/config >/dev/null
		printf ' User root\n' | $sudo tee -a $1/.ssh/config >/dev/null
	fi
	$sudo chmod 600 $1/.ssh/config
}
_user_bootstrap() {
	$_SUDO_CMD mkdir -p /root/.ssh/socket
	$_SUDO_CMD chmod -R 700 /root/.ssh/socket
	app-install configuration
}
_user_install() {
	_users_add "$1"
}
_user_uninstall() {
	. "$1"
	_require "$username" "username"
	rmuser -y $username
}
_user_is_installed() {
	:
}
_user_enabled() {
	return 0
}
_users_add_argument() {
	if [ -n "$2" ]; then
		user_options="$user_options $1 $2"
	fi
}
_users_add() {
	. $1
	if [ "root" != "$username" ]; then
		$_SUDO_CMD pw user show $username >/dev/null 2>&1 || {
			_info "### Add User: $1: $username"
			user_options="-n $username -m"
			_users_add_argument "-g" "$gid"
			_users_add_argument "-G" "$grouplist"
			_users_add_argument "-s" "$shell"
			_users_add_argument "-u" "$uid"
			$_SUDO_CMD pw useradd $user_options
		}
	else
		_info "# Setting shell to $shell for root"
		$_SUDO_CMD chsh -s "$shell"
	fi
	if [ -n "$password" ]; then
		_info "# Setting password $shell for $username"
		$_SUDO_CMD chpass -p "$password" $username
	fi
	_users_configure
	_users_cleanup
}
_users_get_data() {
	printf '%s\n' "$username" | tr ' ' '\n'
}
_users_cleanup() {
	unset user_options username gid grouplist shell uid password system
}
_users_configure() {
	local user_home=$(grep "^$username:" /etc/passwd | cut -f6 -d':')
	sudo=$SUDO_CMD _prepare_ssh_conf $user_home $username
	local original_pwd=$PWD
	cd /tmp
	if [ -n "$system" ]; then
		_warn "$username is a system user, bypassing configuration"
	else
		_warn "_CONF_FREEBSD_INSTALLER_HOSTNAME:$_CONF_FREEBSD_INSTALLER_HOSTNAME"

		_WARN_ON_ERROR=1 _NON_INTERACTIVE=1 _FREEBSD_INSTALLER=1 _NO_WRITE_STDERR=1 _ $_SUDO_CMD --preserve-env=_CONF_GIT_MIRROR,_WARN_ON_ERROR,_LOG_TARGET,_NON_INTERACTIVE,_CONF_FREEBSD_INSTALLER_HOSTNAME,_NO_WRITE_STDERR,http_proxy,https_proxy -H -u $username conf restore || {
			_user_configure_debug
		}
	fi
	cd $original_pwd
}
_user_configure_debug() {
	_warn "Error restoring configuration for $username"
	cat $user_home/.ssh/id_ecdsa.pub
	cat $user_home/.ssh/authorized_keys
	cat $user_home/.ssh/config
}
_users() {
	_user_bootstrap
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/*.user\""
	fi
	local _USER_PATH
	for _USER_PATH in $(find patches -type f -path '*/*.patch/*.user' $variant_options | sort); do
		_users_add $_USER_PATH
	done
	unset _CONFIGURATION_INSTALLED
}
