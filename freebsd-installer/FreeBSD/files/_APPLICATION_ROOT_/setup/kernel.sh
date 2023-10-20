_require_file() {
	if [ -z "$1" ]; then
		_error "Filename is missing ($_FILE_DETAIL_MESSAGE)"
	fi
	if [ ! -e $1 ]; then
		if [ $# -eq 2 ]; then
			_warn "File: $1 does not exist ($_FILE_DETAIL_MESSAGE)"
			return 1
		fi
		_error "File: $1 does not exist ($_FILE_DETAIL_MESSAGE)"
	fi
}
_readlink() {
	if [ $# -lt 1 ] || [ -z "$1" ]; then
		return 1
	fi
	if [ "$1" = "/" ]; then
		printf '%s\n' "$1"
		return
	fi
	if [ ! -e $1 ]; then
		if [ -z $_MKDIR ] || [ $_MKDIR -eq 1 ]; then
			local sudo
			if [ -n "$_USE_SUDO" ]; then
				sudo=$_SUDO_CMD
			fi
			$sudo mkdir -p $1 >/dev/null 2>&1
		fi
	fi
	readlink -f $1
}
_kernel_jail=0
_kernel() {
	_info "Building kernel"
	_SYSTEM_VERSION=$(uname -r | sed -e "s/\-.*//")
	_SYSTEM_ARCHITECTURE=$(uname -m)
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/kernel\""
	fi
	local kernel_patch_path=$(find patches -type d -path '*/*.patch/kernel' $variant_options | head -1)
	_require_file "$kernel_patch_path"
	if [ -e $kernel_patch_path/make.conf ]; then
		cp $kernel_patch_path/make.conf /etc
	fi
	if [ $(grep -c cpuctl /etc/make.conf) -eq 0 ]; then
		_warn "Enabling CPU microcode update support by including cpuctl as a kernel module"
		$_CONF_INSTALL_GNU_SED -i 's/MODULES_OVERRIDE=/MODULES_OVERRIDE=cpuctl /' /etc/make.conf
	fi
	local system_configuration=/usr/src/sys/$_SYSTEM_ARCHITECTURE/conf
	if [ ! -e $system_configuration ]; then
		git clone -b releng/$_SYSTEM_VERSION --depth 1 https://git.freebsd.org/src.git /usr/src
		cp $kernel_patch_path/kernel $system_configuration/custom
	fi
	cd /usr/src
	kernel_out=$(mktemp)
	kernel_error=$(mktemp)
	make buildkernel KERNCONF=custom >$kernel_out 2>$kernel_error || {
		_kernel_output Build
		return 1
	}
	make installkernel KERNCONF=custom >$kernel_out 2>$kernel_error || {
		_kernel_output Install
		return 2
	}
	_kernel_output
	$_CONF_INSTALL_GNU_SED -i "s/Components src world kernel/Components src world/" /etc/freebsd-update.conf
	_info "kernel build complete"
}
_kernel_output() {
	if [ $# -gt 0 ]; then
		_warn "$1 kernel failed"
		cat $kernel_out $kernel_error
	fi
	rm -f $kernel_out $kernel_error
	unset kernel_out kernel_error
}
