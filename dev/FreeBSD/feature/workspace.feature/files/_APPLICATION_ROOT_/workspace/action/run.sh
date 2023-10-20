#import feature/workspace.feature/workspace/action/start.sh
_workspace_run() {
	if [ $# -eq 0 ]; then
		_error "Expected at least 1 argument, cmd to run."
	fi
	_workspace_current_activity || {
		#_workspace_start
		workspace --start
	}
	_LOG_FILE=$_CURRENT_ACTIVITY_DIRECTORY/$(_current_time_unix_epoch)
	printf '# cmdline: %s\n' "$@" >>$_LOG_FILE
	"$@"
	printf '# run after:\n' >>$_LOG_FILE
	_GIT_ADD=1 _workspace_git "$_WORKSPACE_LABEL - run" $_LOG_FILE
}
