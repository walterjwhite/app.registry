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
_git() {
	_prepare_ssh_conf $HOME $USER
	_prepare_etc_hosts
	git clone $_CONF_FREEBSD_INSTALLER_SYSTEM_GIT -b $_CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH $_SYSTEM_REPOSITORY_PATH || _error "Error cloning $_CONF_FREEBSD_INSTALLER_SYSTEM_GIT"
	cd $_SYSTEM_REPOSITORY_PATH
	###
	git branch --no-color --show-current >$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	git log --pretty=medium --no-color -1 >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	printf 'Configuration Date: %s\n' "$(date)" >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	printf 'Node: %s\n' "$(uuidgen)" >>$_CONF_FREEBSD_INSTALLER_SYSTEM_IDENTIFICATION
	_SYSTEM_HASH=$(git rev-parse HEAD)
}
_prepare_etc_hosts() {
	if [ "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" = "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" ]; then
		printf '%s git freebsd-package-cache\n' "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" >>/etc/hosts
	else
		printf '%s git\n' "$_CONF_FREEBSD_INSTALLER_GIT_MIRROR" >>/etc/hosts
		printf '%s freebsd-package-cache\n' "$_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE" >>/etc/hosts
	fi
}
