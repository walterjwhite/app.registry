_do_chown() {
	. $1
	chown $options $owner:$group $path
	unset owner group path options
}
_chown() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/chown/*\""
	fi
	local _CHOWN_PATH
	for _CHOWN_PATH in $(find patches -type f -path '*/*.patch/chown/*' $variant_options | sort); do
		_do_chown $_CHOWN_PATH
	done
}
