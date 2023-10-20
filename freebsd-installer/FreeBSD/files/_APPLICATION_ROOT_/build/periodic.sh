_periodic() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/periodic/*\""
	fi
	find patches -type f -path '*/*.patch/periodic/*' $variant_options -exec $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/bin/_key_value /etc/periodic.conf {} sysrc \;
}
