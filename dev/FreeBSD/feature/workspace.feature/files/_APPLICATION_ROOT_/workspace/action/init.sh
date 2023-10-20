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
_workspace_init() {
	if [ ! -e "$_WORKSPACE_WORKSPACE_PATH" ]; then
		_info "Initializing workspace @ $_WORKSPACE_WORKSPACE_PATH"
		if [ -n "$_CONF_DEV_WORKSPACE_WORKSPACE_MIRROR" ]; then
			git clone $_CONF_DEV_WORKSPACE_WORKSPACE_MIRROR $_WORKSPACE_WORKSPACE_PATH
		else
			git init $_WORKSPACE_WORKSPACE_PATH
			cd $_WORKSPACE_WORKSPACE_PATH
			touch .gitignore && _GIT_ADD=1 _workspace_git 'initialized' .gitignore
		fi
	fi
	if [ -z "$_ACTION_ARGUMENT" ]; then
		if [ -z "$_WORKSPACE_ID" ]; then
			_warn "No action specified, no workspace to setup"
			return
		fi
	else
		_WORKSPACE_DIR=$_WORKSPACE_WORKSPACE_PATH/active/$_ACTION_ARGUMENT
		. $_WORKSPACE_PATH
	fi
	if [ ! -e "$_WORKSPACE_DIR" ]; then
		mkdir -p $_WORKSPACE_DIR
	fi
	_WORKSPACE_PATH="$_WORKSPACE_DIR/.context"
	if [ ! -e $_WORKSPACE_PATH ]; then
		touch $_WORKSPACE_PATH
		_warn "Please update $_WORKSPACE_PATH and re-run to initialize sub-modules"
		return
	fi
	mkdir -p $_WORKSPACE_DIR/projects
	_WORKSPACE_GIT_CONFIG="$_WORKSPACE_DIR/.context.git"
	if [ ! -e $_WORKSPACE_GIT_CONFIG ]; then
		touch $_WORKSPACE_GIT_CONFIG
		_warn "Please update $_WORKSPACE_GIT_CONFIG and re-run to initialize sub-modules"
		return
	fi
	if [ $(wc -l $_WORKSPACE_GIT_CONFIG) -eq 0 ]; then
		_warn "No workspace git dependencies were specified"
		return
	fi
	if [ -z "$_WORKSPACE_SUMMARY" ]; then
		_warn "Please enter a _WORKSPACE_SUMMARY"
	fi
	if [ -z "$_WORKSPACE_TIME_ESTIMATE" ]; then
		_warn "Please enter a _WORKSPACE_TIME_ESTIMATE"
	fi
	$_CONF_INSTALL_GNU_GREP -Pv '(^$|^#)' $_WORKSPACE_GIT_CONFIG | xargs -I _WORKSPACE_GIT_DEPENDENCY -P $_CONF_DEV_WORKSPACE_PARALLEL_CHECKOUT $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/workspace/bin/workspace-module-init _WORKSPACE_GIT_DEPENDENCY
	_GIT_ADD=1 _workspace_git 'initialized - workspace' $_WORKSPACE_PATH $_WORKSPACE_DIR/projects $_WORKSPACE_WORKSPACE_PATH/.gitmodules
}
