_conf_intellij_get_directory() {
	_PLUGIN_CONFIGURATION_PATH=$(find "$1" -maxdepth 1 -type d -name '*Idea*' 2>/dev/null)
	if [ $? -gt 0 ]; then
		unset _PLUGIN_CONFIGURATION_PATH
		return
	fi
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="keymaps options"
}
case $_PLATFORM in
Windows)
	_conf_intellij_get_directory ~/AppData/IntelliJ
	;;
Apple)
	_conf_intellij_get_directory ~/Library/"Application Support"/JetBrains
	;;
Linux | FreeBSD)
	_conf_intellij_get_directory ~/.config/JetBrains
	;;
esac
