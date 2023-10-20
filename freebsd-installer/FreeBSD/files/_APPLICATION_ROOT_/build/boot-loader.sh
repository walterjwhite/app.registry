_boot_loader_jail=0
_boot_loader() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/boot-loader/*\""
	fi
	find patches -type f -path '*/*.patch/boot-loader/*' $variant_options -exec $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/bin/_key_value /boot/loader.conf {} sysctl \;
}
