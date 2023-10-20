#import feature/workspace.feature/workspace/action/start.sh
_workspace_comment() {
	_REQUIRE_DETAILED_MESSAGE="must perform action within workspace" _require "$_WORKSPACE_DIR" _WORKSPACE_DIR
	_workspace_current_activity || {
		#_workspace_start
		workspace --start
	}
	local _comment_file=$_CURRENT_ACTIVITY_DIRECTORY/$(_current_time_unix_epoch)
	printf '%s\n' "$_ACTION_ARGUMENT" >>$_comment_file
	_GIT_ADD=1 _workspace_git "$_WORKSPACE_LABEL - comment" $_comment_file
}
