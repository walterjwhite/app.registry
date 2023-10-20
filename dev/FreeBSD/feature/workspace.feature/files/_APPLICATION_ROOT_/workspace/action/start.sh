_workspace_start_open_editors() {
	for _WORKSPACE_PROJECT_GIT in $(find $_WORKSPACE_DIR -type f -name .git); do
		_WORKSPACE_PROJECT_PATH=$(dirname $_WORKSPACE_PROJECT_GIT)
		_WORKSPACE_PROJECT_NAME=$(basename $_WORKSPACE_PROJECT_PATH)
		local _editor=$(env | grep "^_WORKSPACE_EDITOR_${_WORKSPACE_PROJECT_NAME}=" | sed -e 's/^.*=//')
		if [ -z "$_editor" ]; then
			_editor=$_WORKSPACE_EDITOR
		fi
		ide --open --ide=$_editor --project=$_WORKSPACE_PROJECT_PATH &
		printf '%s\n' $! >>$_WORKSPACE_DIR/.pid
	done
}
_workspace_start() {
	_workspace_current_activity && {
		_warn "Latest activity ($_CURRENT_ACTIVITY_NAME) is already started"
		return
	}
	_info "Starting $_WORKSPACE_DIR"
	_CURRENT_ACTIVITY_DIRECTORY=$_WORKSPACE_DIR/.activity/current-$(_current_time_unix_epoch)
	mkdir -p $_CURRENT_ACTIVITY_DIRECTORY
	touch $_CURRENT_ACTIVITY_DIRECTORY/.init
	_GIT_ADD=1 _workspace_git 'start' $_CURRENT_ACTIVITY_DIRECTORY
	_workspace_start_open_editors
}
