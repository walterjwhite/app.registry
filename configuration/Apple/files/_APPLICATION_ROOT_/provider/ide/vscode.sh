case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.config/"Code - OSS"
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="User/keybindings.json User/settings.json"
	;;
Apple)
	_PLUGIN_CONFIGURATION_PATH="$HOME/Library/Application Support/Code"
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="User/keybindings.json User/settings.json"
	;;
esac
