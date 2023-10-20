_pkg_install() {
	_pkg_bootstrap
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg install" pkg $_PKG_OPTIONS install -yq $@ >/dev/null
}
_pkg_uninstall() {
	_pkg_bootstrap
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg uninstall" pkg $_PKG_OPTIONS delete -yq $@ >/dev/null
}
_pkg_is_installed() {
	_pkg_bootstrap
	pkg $_PKG_OPTIONS info -e $1 2>/dev/null
}
_pkg_bootstrap() {
	[ $_PKG_BOOTSTRAPPED ] && return
	ASSUME_ALWAYS_YES=yes
	_PKG_BOOTSTRAPPED=1
	if [ -n "$_ROOT" ] && [ "$_ROOT" != "/" ]; then
		_pkg_cache_already_mounted || _pkg_cache_mount
		_PKG_OPTIONS="-r $_ROOT"
	fi
	_pkg_enable_proxy
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg bootstrap" pkg $_PKG_OPTIONS update -q
}
_pkg_cache_already_mounted() {
	mount | awk {'print$3'} | grep -q "$_ROOT/var/cache/pkg$"
}
_pkg_cache_mount() {
	$_SUDO_CMD mkdir -p $_ROOT/var/cache/pkg
	_info "Mounting host's package cache"
	$_SUDO_CMD mount -t nullfs /var/cache/pkg $_ROOT/var/cache/pkg || {
		_warn "Error mounting host's package cache"
		_warn "pkg cache mounts: $(mount | awk {'print$3'} | grep \"^$_ROOT/var/cache/pkg$\")"
		_warn "mounts: $(mount | awk {'print$3'})"
		return 1
	}
	_defer _pkg_cache_umount
}
_pkg_cache_umount() {
	umount $_ROOT/var/cache/pkg
}
_pkg_bootstrap_platform() {
	_pkg_bootstrap
}
_pkg_bootstrap_is_pkg_available() {
	return 0
}
_pkg_enable_proxy() {
	if [ -z "$http_proxy" ]; then
		return
	fi
	[ $_PKG_PROXY_ENABLED ] && return
	_PKG_PROXY_ENABLED=1
	_defer _pkg_disable_proxy
	_warn "[install] Configuring pkg to use an HTTP proxy: $http_proxy"
	local _updated_pkg_conf=$(mktemp)
	if [ -e $_ROOT/usr/local/etc/pkg.conf ]; then
		grep -v '^pkg_env' $_ROOT/usr/local/etc/pkg.conf >$_updated_pkg_conf
		mv $_updated_pkg_conf $_ROOT/usr/local/etc/pkg.conf
	fi
	mkdir -p $_ROOT/usr/local/etc
	printf 'pkg_env: { http_proxy: "%s"}\n' "$http_proxy" >>$_ROOT/usr/local/etc/pkg.conf
}
_pkg_disable_proxy() {
	if [ -z "$http_proxy" ]; then
		return
	fi
	unset _PKG_PROXY_ENABLED
	_warn "[freebsd-installer] Disabling HTTP proxy: $http_proxy"
	$_CONF_INSTALL_GNU_SED -i "s/^pkg_env/#pkg_env/" $_ROOT/usr/local/etc/pkg.conf
}
_pkg_setup_ssh_package_cache() {
	if [ $# -lt 1 ]; then
		_error "SSH host is required to setup ssh cache"
	fi
	_pkg_install fusefs-sshfs || _error "Error installing fusefs-sshfs"
	kldload /boot/kernel/fusefs.ko
	mv /var/cache/pkg /var/cache/pkg.local
	mkdir -p /var/cache/pkg
	sshfs -o StrictHostKeyChecking=no :/var/cache/pkg /var/cache/pkg
	mv -f /var/cache/pkg.local/* /var/cache/pkg
	rm -rf /var/cache/pkg.local
	_defer _cleanup_package_cache $1
}
_pkg_cleanup_ssh_package_cache() {
	umount /var/cache/pkg
	kldunload fusefs
}
_go_bootstrap() {
	_go_bootstrap_is_go_available || {
		_go_bootstrap_platform
		_go_bootstrap_is_go_available || _GO_DISABLED=1
	}
	_go_setup_proxy
}
_go_bootstrap_is_go_available() {
	which go >/dev/null 2>&1
}
_go_install() {
	_USE_SUDO=1 _PRESERVE_ENV=1 GO111MODULE=on _timeout $_CONF_INSTALL_STEP_TIMEOUT "go install" go install $_GO_OPTIONS "$@" || {
		_warn "go install failed: $_GO_OPTIONS $@"
		_warn "  http_proxy: $http_proxy"
		_warn "  git  proxy: $(git config --global http.proxy)"
	}
}
_go_update() {
	:
}
_go_uninstall() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "go uninstall" go uninstall "$@"
}
_go_is_installed() {
	return 1
}
_go_is_file() {
	return 1
}
_go_setup_proxy() {
	if [ -n "$http_proxy" ]; then
		_warn "Configuring git to use an HTTP proxy: $http_proxy"
		git config --global http.proxy $http_proxy
		git config --global https.proxy $http_proxy
		#GOPROXY="$http_proxy"
		_defer _go_clear_proxy
	fi
}
_go_clear_proxy() {
	_warn "Reverting git HTTP proxy: $http_proxy"
	git config --unset --global http.proxy
	git config --unset --global https.proxy
	#unset GOPROXY
}
_time_seconds_to_human_readable() {
	_HUMAN_READABLE_TIME=$(printf '%02d:%02d:%02d' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60)))
}
_time_human_readable_to_seconds() {
	case $1 in
	*w)
		_TIME_IN_SECONDS=${1%%w}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600 * 8 * 5))
		;;
	*d)
		_TIME_IN_SECONDS=${1%%d}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600 * 8))
		;;
	*h)
		_TIME_IN_SECONDS=${1%%h}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600))
		;;
	*m)
		_TIME_IN_SECONDS=${1%%m}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 60))
		;;
	*s)
		_TIME_IN_SECONDS=${1%%s}
		;;
	*)
		_error "$1 was not understood"
		;;
	esac
}
_time_decade() {
	local year=$(date +%Y)
	local _end_year=$(printf '%s' $year | head -c 4 | tail -c 1)
	local _event_decade_prefix=$(printf '%s' "$year" | $_CONF_INSTALL_GNU_GREP -Po "[0-9]{3}")
	if [ "$_end_year" -eq "0" ]; then
		_event_decade_start=${_event_decade_prefix}
		_event_decade_start=$(printf '%s' "$_event_decade_start-1" | bc)
		_event_decade_end=${_event_decade_prefix}0
	else
		_event_decade_start=$_event_decade_prefix
		_event_decade_end=$_event_decade_prefix
		_event_decade_end=$(printf '%s' "$_event_decade_end+1" | bc)
		_event_decade_end="${_event_decade_end}0"
	fi
	_event_decade_start=${_event_decade_start}1
	printf '%s-%s' "$_event_decade_start" "$_event_decade_end"
}
_current_time() {
	date +$_CONF_INSTALL_DATE_TIME_FORMAT
}
_current_time_unix_epoch() {
	date +%s
}
_timeout() {
	local timeout=$1
	shift
	local message=$1
	shift
	local timeout_units='s'
	if [ $(printf '%s' "$timeout" | grep -c '[smhd]{1}') -gt 0 ]; then
		unset timeout_units
	fi
	local timeout_level=error
	if [ $_WARN ]; then
		timeout_level=warn
	fi
	local sudo_prefix
	[ $_USE_SUDO ] && {
		[ -z "$USER" ] && USER=$(whoami)
		[ "$USER" != "root" ] && {
			sudo_prefix=$_SUDO_CMD
			[ $_PRESERVE_ENV ] && sudo_prefix="$sudo_prefix -E"
		}
	}
	$sudo_prefix timeout $_OPTIONS $timeout "$@" || {
		local error_status=$?
		local error_message="Other error"
		if [ $error_status -eq 124 ]; then
			error_message="Timed Out"
		fi
		[ $_TIMEOUT_ERR_FUNCTION ] && $_TIMEOUT_ERR_FUNCTION
		_$timeout_level "_timeout: $error_message: ${timeout}${timeout_units} - $message ($error_status): $sudo_prefix timeout $_OPTIONS $timeout $* ($USER)"
		return $error_status
	}
}
_go() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/go\""
	fi
	if [ $(find patches -type f -path '*/*.patch/go' $variant_options -print -quit | wc -l) -eq 0 ]; then
		_warn "No go packages found"
		return 1
	fi
	_pkg_install go
	GOPATH=/usr/local
	_go_setup_proxy
	find patches -type f -path '*/*.patch/go' $variant_options -exec $_CONF_INSTALL_GNU_GREP -P '^[\w]{6,}' {} \; | xargs -L 1 $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/bin/_go
}
