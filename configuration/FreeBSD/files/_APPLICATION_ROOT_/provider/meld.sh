_PLUGIN_CONFIGURATION_PATH=~/.config
_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
_PLUGIN_CONFIGURATION_PATH_IS_SKIP_PREPARE=1
_GSETTINGS_MELD_KEY=org.gnome.meld
_gsettings_dump() {
	gsettings list-recursively "$1" | sed -e "s/^$1 //"
}
_gsettings_restore() {
	local _gsettings_line
	local _gsettings_key _gsettings_value
	while read _gsettings_line; do
		_gsettings_key=$(printf '%s' "$_gsettings_line" | sed -e 's/ .*//')
		_gsettings_value=$(printf '%s' "$_gsettings_line" | sed -e 's/[[:alnum:]-]* //')
		gsettings set $2 "$_gsettings_key" "$_gsettings_value"
	done <"$1"
}
_configure_meld_backup() {
	mkdir -p $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME
	_gsettings_dump $_GSETTINGS_MELD_KEY >$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/gsettings.conf
}
_configure_meld_restore() {
	_gsettings_restore $_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME/gsettings.conf $_GSETTINGS_MELD_KEY 2>/dev/null
}
