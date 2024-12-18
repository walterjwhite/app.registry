case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.config/evolution
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_EXCLUDE=".running"
	;;
esac
