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
_workspace_submodule_do() {
	grep path $_WORKSPACE_DIR/.gitmodules | awk {'print$3'} | xargs -I _SUBMODULE_PATH -P $_CONF_DEV_WORKSPACE_PARALLEL_CHECKOUT git submodule $1 _SUBMODULE_PATH
}
_workspace_update() {
	_info "Updating git submodules"
	_workspace_submodule_do init
	_workspace_submodule_do update
}
