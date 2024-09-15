_PLUGIN_CONFIGURATION_PATH=~/.gnupg
_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
_PLUGIN_EXCLUDE="random_seed .#*"
_configure_gnupg_restore_post() {
	chmod 700 "$_PLUGIN_CONFIGURATION_PATH"
}
