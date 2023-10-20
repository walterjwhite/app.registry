_workspace_move_active() {
	_WORKSPACE_TAG_PATH=$(_workspace_tags_path)
	_WORKSPACE_ACTIVE_PATH=$_WORKSPACE_WORKSPACE_PATH/$1/$_WORKSPACE_TAG_PATH/$2
	mkdir -p $_WORKSPACE_ACTIVE_PATH
	local original_workspace_dir=$_WORKSPACE_DIR
	git mv $_WORKSPACE_DIR $_WORKSPACE_ACTIVE_PATH
	_WORKSPACE_DIR=$_WORKSPACE_ACTIVE_PATH/$_WORKSPACE_ID
	cd $_WORKSPACE_DIR
	local workspace_path=$(_sed_safe $_WORKSPACE_WORKSPACE_PATH)
	_WORKSPACE_DIR_RELATIVE=$(printf '%s' $_WORKSPACE_DIR | sed -e "s/$workspace_path//" -e 's/^\///' -e 's/\/\//\//g')
	_workspace_git "mark $_WORKSPACE_LABEL $1" $_WORKSPACE_DIR $original_workspace_dir $_WORKSPACE_WORKSPACE_PATH/.gitmodules
}
_sed_safe() {
	printf '%s' $1 | sed -e "s/\//\\\\\//g"
}
_workspace_active() {
	_workspace_move_active active
	_warn "Init submodules under $_WORKSPACE_DIR"
	cd $_WORKSPACE_WORKSPACE_PATH
	grep path $_WORKSPACE_WORKSPACE_PATH/.gitmodules | awk {'print$3'} | grep "$_WORKSPACE_DIR_RELATIVE" |
		xargs -I _SUBMODULE_PATH -P $_CONF_DEV_WORKSPACE_PARALLEL_CHECKOUT git submodule init _SUBMODULE_PATH
	grep path $_WORKSPACE_WORKSPACE_PATH/.gitmodules | awk {'print$3'} | grep "$_WORKSPACE_DIR_RELATIVE" |
		xargs -I _SUBMODULE_PATH -P $_CONF_DEV_WORKSPACE_PARALLEL_CHECKOUT git submodule update _SUBMODULE_PATH
}
