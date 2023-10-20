_PLUGIN_CONFIGURATION_PATH=~/.data
_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
_PLUGIN_CONFIGURATION_PATH_IS_SKIP_PREPARE=1
_configure_data_application_restore_pre() {
	_SYSTEM=$(head -1 /usr/local/etc/walterjwhite/system 2>/dev/null)
}
_configure_walterjwhite_data_restore() {
	local data_application
	while read data_application; do
		if [ -e ~/.data/$data_application ]; then
			_warn "Data Application: $data_application already exists"
			continue
		fi
		gclone data/$_SYSTEM/$USER/$data_application ~/.data/$data_application
	done <$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/applications
}
_configure_walterjwhite_data_backup() {
	rm -f $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/applications
	basename $(find $_PLUGIN_CONFIGURATION_PATH -maxdepth 2 -type d -name .git | sed -e 's/\/.git//' -e 's/\.\///' | sort -u) >>$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/applications
}
