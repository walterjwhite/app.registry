case $_PLATFORM in
Apple)
	_PLUGIN_CONFIGURATION_PATH=~/Library/Preferences
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	;;
esac
_configure_apple_restore_post() {
	pkill -1 -lf Rectangle.app
	pkill -1 -lf DBeaver.app
	pkill -1 -lf Insomnia.app
	pkill -1 -lf Mockoon.app
	pkill -1 -lfi karabiner
	pkill -1 -lf jetbrains
}
