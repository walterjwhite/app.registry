if [ -n "$_ACTION_ARGUMENT" ]; then
	_CONF_DEV_WORKSPACE_TAIL=$_ACTION_ARGUMENT
fi
_workspace_tail_do() {
	for _ACTIVITY in $(find $_WORKSPACE_DIR/.activity/$_WORKSPACE_ACTIVITY_DIR -type d -maxdepth 1 ! -name 'archived' "$@" 2>/dev/null | sort | tail -$_CONF_DEV_WORKSPACE_TAIL); do
		_ACTIVITY_TIME=$(basename $_ACTIVITY | sed -e 's/current-//')
		_ACTIVITY_START_TIME="${_ACTIVITY_TIME%%-*}"
		_ACTIVITY_STOP_TIME="${_ACTIVITY_TIME#*-}"
		if [ "$_ACTIVITY_START_TIME" == "$_ACTIVITY_STOP_TIME" ]; then
			_ACTIVITY_STOP_TIME="now (in-progress)"
		else
			_ACTIVITY_STOP_TIME=$(date -r $_ACTIVITY_STOP_TIME +"$_CONF_DEV_WORKSPACE_TIME_FORMAT")
		fi
		_ACTIVITY_START_TIME=$(date -r $_ACTIVITY_START_TIME +"$_CONF_DEV_WORKSPACE_TIME_FORMAT")
		_detail "[$_ACTIVITY_START_TIME - $_ACTIVITY_STOP_TIME]"
		for _ACTIVITY_INSTANCE in $(find $_ACTIVITY -type f ! -name '.init'); do
			_ACTIVITY_INSTANCE_SUMMARY=$(head -1 $_ACTIVITY_INSTANCE)
			if [ -n "$_ACTIVITY_INSTANCE_SUMMARY" ]; then
				_ACTIVITY_INSTANCE_TIME=$(basename $_ACTIVITY_INSTANCE)
				_detail "+ $(date -r $_ACTIVITY_INSTANCE_TIME +"$_CONF_DEV_WORKSPACE_TIME_FORMAT") $_ACTIVITY_INSTANCE_SUMMARY"
			fi
		done
	done
}
_workspace_tail() {
	_workspace_tail_do -name 'current-*'
	_WORKSPACE_ACTIVITY_DIR=archived _workspace_tail_do
}
