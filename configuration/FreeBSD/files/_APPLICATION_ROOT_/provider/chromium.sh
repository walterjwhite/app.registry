case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.config/chromium
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="Default/Preferences Default/Extensions Default/Bookmarks"
	;;
Apple)
	_PLUGIN_CONFIGURATION_PATH=~/Library/"Application Support"/Google/Chrome
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="Default/Preferences Default/Extensions Default/Bookmarks"
	;;
esac
