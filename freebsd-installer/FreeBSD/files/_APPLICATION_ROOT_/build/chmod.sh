_do_chmod() {
	. $1
	chmod $options $mode $path
	unset mode path options
}
_chmod() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/chmod/*\""
	fi
	local _CHMOD_PATH
	for _CHMOD_PATH in $(find patches -type f -path '*/*.patch/chmod/*' $variant_options | sort); do
		_do_chmod $_CHMOD_PATH
	done
}
