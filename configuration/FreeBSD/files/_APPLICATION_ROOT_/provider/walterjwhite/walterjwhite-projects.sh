_PLUGIN_CONFIGURATION_PATH=~/projects
_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
_PLUGIN_CONFIGURATION_PATH_IS_SKIP_PREPARE=1
_configure_walterjwhite_projects_restore() {
	local opwd=$PWD
	local project
	while read project; do
		if [ -e ~/.data/$project ]; then
			_warn "Data Application: $project already exists"
			continue
		fi
		gclone $project
		cd $opwd
	done <$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/projects
}
_configure_walterjwhite_projects_backup() {
	rm -f $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/projects
	find $_PLUGIN_CONFIGURATION_PATH -name .git -type d ! -path '*/app.registry/*' |
		sed -e 's/\/.git//' -e 's/^.*\/projects\///' -e 's/github.com/git@github.com/' -e 's/git\///' |
		sort -u >>$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/projects
}
