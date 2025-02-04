_integrity_Apple_Homebrew() {
	$_CONF_INSTALL_GNU_GREP -P ': /opt/homebrew' $_INTEGRITY_RAW_DATA_FILE >>$_INTEGRITY_PLUGIN_DATA_PATH
	printf '\n' >>$_INTEGRITY_PLUGIN_DATA_PATH
}
