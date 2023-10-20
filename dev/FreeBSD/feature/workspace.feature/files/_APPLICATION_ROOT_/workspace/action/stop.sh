_workspace_stop() {
	if [ $# -gt 0 ]; then
		_SKIP_PROJECT_WORKSPACE=$(readlink -f $1)
		shift
	fi
	if [ -n "$_SKIP_PROJECT_WORKSPACE" ]; then
		if [ "$_SKIP_PROJECT_WORKSPACE" = "$_WORKSPACE_DIR" ]; then
			_warn "skipping $_SKIP_PROJECT_WORKSPACE"
			return
		fi
	fi
	_workspace_current_activity || return
	_info "Stopping $_LATEST_ACTIVITY_TIME"
	_warn "Killing workspace processes"
	_kill_all_group
	mkdir -p $_WORKSPACE_DIR/.activity/archived
	local _target_activity_directory=$_WORKSPACE_DIR/.activity/archived/$_CURRENT_ACTIVITY_START_TIME-$_CURRENT_ACTIVITY_STOP_TIME
	local _original_pwd=$PWD
	cd $_WORKSPACE_DIR
	git mv $_CURRENT_ACTIVITY_DIRECTORY $_target_activity_directory
	cd $_original_pwd
	_workspace_git 'stop' $_CURRENT_ACTIVITY_DIRECTORY $_target_activity_directory
}
