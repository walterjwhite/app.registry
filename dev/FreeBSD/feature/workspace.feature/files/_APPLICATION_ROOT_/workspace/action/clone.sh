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
_workspace_clone() {
	_require "$_ACTION_ARGUMENT" _ACTION_ARGUMENT
	local _workspace_source=${_ACTION_ARGUMENT%%,*}
	local _workspace_source_path=$(find $_WORKSPACE_WORKSPACE_PATH/active -type d -name $_workspace_source -maxdepth 1)
	local _workspace_target=${_ACTION_ARGUMENT#*,}
	local _workspace_target_path=$_WORKSPACE_WORKSPACE_PATH/active/$_workspace_target
	if [ "$_workspace_target" == "$_workspace_source" ]; then
		_warn "ie. --clone=source-workspace-id,target-workspace-id (workspace must be active)"
		_error "Target cannot be the same as the source"
	fi
	_require "$_workspace_target" _workspace_target
	_require_file $_workspace_source_path/.context
	mkdir -p $_workspace_target_path
	cp $_workspace_source_path/.context $_workspace_target_path
	_GIT_ADD=1 _workspace_git "clone ($_workspace_source -> $_workspace_target)" $_workspace_target_path
	_info "Initializing workspace: $_workspace_target"
	workspace --init=active/$_workspace_target
}
