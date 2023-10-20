case $_PLATFORM in
Windows)
	_PLUGIN_CONFIGURATION_PATH=$APPDATA/DBeaverData
	;;
Apple)
	_PLUGIN_CONFIGURATION_PATH=~/Library/DBeaverData
	;;
Linux | FreeBSD)
	if [ -n "$XDG_DATA_HOME" ]; then
		_PLUGIN_CONFIGURATION_PATH=$XDG_DATA_HOME/DBeaverData
	else
		_PLUGIN_CONFIGURATION_PATH=~/.local/share/DBeaverData
	fi
	;;
esac
_dbeaver_init_include() {
	local OPWD=$PWD
	cd $_PLUGIN_CONFIGURATION_PATH
	_PLUGIN_INCLUDE=$(find . -type f -path '*/.settings/*' -or -name 'data-sources.json' -or -name 'credentials-config.json' -or -name 'project-metadata.json' | tr '\n' ' ')
	cd $OPWD
}
_configure_dbeaver_backup_post() {
	find "$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME" -type f -exec $_CONF_INSTALL_GNU_SED -i '/SQLEditor.resultSet.ratio=.*/d' {} +
	find "$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME" -type f -exec $_CONF_INSTALL_GNU_SED -i '/ui.auto.update.check.time=.*/d' {} +
}
if [ ! -e $_PLUGIN_CONFIGURATION_PATH ]; then
	unset _PLUGIN_CONFIGURATION_PATH
else
	_dbeaver_init_include
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
fi
_dbeaver_decrypt() {
	local credentials_file
	case $_PLATFORM in
	Apple)
		credentials_file=~/Library/DBeaverData/workspace6/General/.dbeaver/credentials-config.json
		;;
	Linux | FreeBSD)
		if [ -n "$XDG_DATA_HOME" ]; then
			credentials_file=$XDG_DATA_HOME/DBeaverData/workspace6/General/.dbeaver/credentials-config.json
		else
			credentials_file=~/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json
		fi
		;;
	esac
	openssl aes-128-cbc -d -K babb4a9f774ab853c96c2d653dfe544a -iv 00000000000000000000000000000000 -in \
		$credentials_file | dd bs=1 skip=16 2>/dev/null
}
