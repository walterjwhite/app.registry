case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.thunderbird
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_EXCLUDE="calendar-data datareporting Mail security_state settings storage .parentlock abook* formhistory.sqlite lock global-messages-db.sqlite"
	_PLUGIN_INCLUDE="installs.ini profiles.ini"
	_THUNDERBIRD_PROFILE_FILES="containers.json \
		encrypted-openpgp-passphrase.txt extension-preferences.json extensions.json \
		key4.db logins.json mailViews.dat openpgp.sqlite permissions.sqlite pkcs11.txt \
		prefs.js session.json sessionCheckpoints.json SiteSecurityServiceState.txt \
		xulstore.json"
	if [ -e "$_PLUGIN_CONFIGURATION_PATH" ]; then
		_THUNDERBIRD_INSTANCE_PATH=$(basename $(find "$_PLUGIN_CONFIGURATION_PATH" -maxdepth 1 -type d ! -name .thunderbird))
		_THUNDERBIRD_MESSAGE_FILTERS=$(find "$_PLUGIN_CONFIGURATION_PATH"/$_THUNDERBIRD_INSTANCE_PATH -type f -name msgFilterRules.dat | sed -e "s/^.*$_THUNDERBIRD_INSTANCE_PATH/$_THUNDERBIRD_INSTANCE_PATH/" | tr '\n' ' ')
		_PLUGIN_INCLUDE="$_PLUGIN_INCLUDE $_THUNDERBIRD_MESSAGE_FILTERS"
		for _THUNDERBIRD_FILE in $_THUNDERBIRD_PROFILE_FILES; do
			_PLUGIN_INCLUDE="$_PLUGIN_INCLUDE $_THUNDERBIRD_INSTANCE_PATH/$_THUNDERBIRD_FILE"
		done
	fi
	;;
esac
_configure_thunderbird_backup_post() {
	local thunderbird_prefs=$(find $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME -type f -name prefs.js -print -quit)
	cat $thunderbird_prefs | sort >$thunderbird_prefs.sorted
	mv $thunderbird_prefs.sorted $thunderbird_prefs
	rm -f $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/extensions
	cp "$_PLUGIN_CONFIGURATION_PATH"/extensions $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME 2>/dev/null
	if [ $(wc -l $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/extensions | awk {'print$1'}) -eq 0 ]; then
		basename $(find "$_PLUGIN_CONFIGURATION_PATH" -type f -path '*/extensions/*.xpi') 2>/dev/null |
			sed -e 's/\.xpi$//' | sort -u >>$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/extensions
	fi
}
_configure_thunderbird_restore_post() {
	cp $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/extensions "$_PLUGIN_CONFIGURATION_PATH"
}
_thunderbird_extensions() {
	_THUNDERBIRD_EXTENSION_PATH=$(find $_INSTANCE_DIRECTORY/.thunderbird -type d -depth 1 -print -quit)/extensions
	rm -rf $_THUNDERBIRD_EXTENSION_PATH && mkdir -p $_THUNDERBIRD_EXTENSION_PATH
	_info "Installing extensions to: $_THUNDERBIRD_EXTENSION_PATH"
	local extension_name
	for extension_name in $(cat $_INSTANCE_DIRECTORY/.mozilla/extensions 2>/dev/null); do
		_browser_extension $extension_name
	done
}
_thunderbird_extension() {
	case $1 in
	sendlater3@kamens.us)
		_thunderbird_extension_load $1 'https://addons.thunderbird.net/thunderbird/downloads/latest/send-later-3/addon-195275-latest.xpi'
		;;
	{a62ef8ec-5fdc-40c2-873c-223b8a6925cc})
		_thunderbird_extension_load $1 'https://addons.thunderbird.net/thunderbird/downloads/latest/provider-for-google-calendar/addon-4631-latest.xpi'
		;;
	*)
		_warn "Unsupported extension: $1"
		continue
		;;
	esac
}
_thunderbird_extension_load() {
	_download $2
	_detail "Copying $_DOWNLOADED_FILE -> $_THUNDERBIRD_EXTENSION_PATH/$1.xpi"
	cp $_DOWNLOADED_FILE $_THUNDERBIRD_EXTENSION_PATH/$1.xpi
}
