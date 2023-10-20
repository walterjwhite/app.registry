_run() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/*.run\""
	fi
	find patches -type f -path '*/*.patch/*.run' $variant_options | sort | xargs -L 1 $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/bin/_run
	return 0
}
