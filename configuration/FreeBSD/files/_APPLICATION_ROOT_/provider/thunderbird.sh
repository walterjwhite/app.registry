case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.thunderbird
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_EXCLUDE="calendar-data datareporting Mail security_state settings storage .parentlock abook* formhistory.sqlite lock global-messages-db.sqlite"
	_PLUGIN_INCLUDE="installs.ini profiles.ini"
	_THUNDERBIRD_PROFILE_FILES="addons.json addonStartup.json.lz4 AlternateServices.txt blist.sqlite cert9.db compatibility.ini containers.json \
		content-prefs.sqlite cookies.sqlite cookies.sqlite-wal directoryTree.json encrypted-openpgp-passphrase.txt extension-preferences.json \
		extensions.json favicons.sqlite favicons.sqlite-wal folderCache.json folderTree.json handlers.json history.sqlite history.sqlite-wal \
		key4.db logins-backup.json logins.json mailViews.dat openpgp.sqlite permissions.sqlite pkcs11.txt places.sqlite places.sqlite-wal \
		prefs.js search.json.mozlz4 session.json session.json.backup sessionCheckpoints.json SiteSecurityServiceState.txt times.json \
		virtualFolders.dat webappsstore.sqlite xulstore.json extensions"
	if [ -e "$_PLUGIN_CONFIGURATION_PATH" ]; then
		_THUNDERBIRD_INSTANCE_PATH=$(basename $(find $_PLUGIN_CONFIGURATION_PATH -maxdepth 1 -type d ! -name .thunderbird))
		_THUNDERBIRD_MESSAGE_FILTERS=$(find $_PLUGIN_CONFIGURATION_PATH/$_THUNDERBIRD_INSTANCE_PATH -type f -name msgFilterRules.dat | sed -e "s/^.*$_THUNDERBIRD_INSTANCE_PATH/$_THUNDERBIRD_INSTANCE_PATH/" | tr '\n' ' ')
		_PLUGIN_INCLUDE="$_PLUGIN_INCLUDE $_THUNDERBIRD_MESSAGE_FILTERS"
		for _THUNDERBIRD_FILE in $_THUNDERBIRD_PROFILE_FILES; do
			_PLUGIN_INCLUDE="$_PLUGIN_INCLUDE $_THUNDERBIRD_INSTANCE_PATH/$_THUNDERBIRD_FILE"
		done
	fi
	;;
esac
