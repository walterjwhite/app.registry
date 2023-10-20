_post_run() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/*.post-run\""
	fi
	find patches -type f -path '*/*.patch/*.post-run' $variant_options | sort | xargs -L 1 $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/bin/_run
	return 0
}
