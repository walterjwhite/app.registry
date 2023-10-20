_conf_datagrip_get_directory() {
	_PLUGIN_CONFIGURATION_PATH=$(find "$1" -maxdepth 1 -type d -name 'DataGrip*' 2>/dev/null)
	if [ $? -gt 0 ]; then
		unset _PLUGIN_CONFIGURATION_PATH
		return
	fi
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="keymaps workspace options"
}
case $_PLATFORM in
Windows)
	_conf_datagrip_get_directory ~/AppData
	;;
Apple)
	_conf_datagrip_get_directory ~/Library/"Application Support"/JetBrains
	;;
Linux | FreeBSD)
	_conf_datagrip_get_directory ~/.config/JetBrains
	;;
esac
