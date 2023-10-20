_app() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/app\""
	fi
	_WARN_ON_CONFIGURATION_VALIDATION_ERRORS=1
	cd $_SYSTEM_REPOSITORY_PATH
	find patches -type f -path '*/*.patch/app' $variant_options -exec $_CONF_INSTALL_GNU_GREP -Pv '(^#|^$)' {} \; | sort | xargs -L 1 app-install
}
