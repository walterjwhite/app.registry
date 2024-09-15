case $_PLATFORM in
Linux | FreeBSD)
	_PLUGIN_CONFIGURATION_PATH=~/.config/pcmanfm
	_PLUGIN_CONFIGURATION_PATH_IS_DIR=1
	_PLUGIN_INCLUDE="default/pcmanfm.conf"
	;;
esac
_configure_pcmanfm_backup_post() {
	local pcmanfm_conf=$(find "$_CONF_INSTALL_APPLICATION_DATA_PATH/$_EXTENSION_NAME" -type f -name pcmanfm.conf)
	if [ -z "$pcmanfm_conf" ]; then
		return 1
	fi
	$_CONF_INSTALL_GNU_SED -i '/win_width=.*/d' $pcmanfm_conf
	$_CONF_INSTALL_GNU_SED -i '/win_height=.*/d' $pcmanfm_conf
	$_CONF_INSTALL_GNU_SED -i '/splitter_pos=.*/d' $pcmanfm_conf
}
