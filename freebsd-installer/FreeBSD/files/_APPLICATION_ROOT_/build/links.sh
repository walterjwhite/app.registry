_link() {
	. $1
	for _TARGET in $targets; do
		_detail "ln -sf $path -> $_TARGET"
		local parent=$(dirname $_TARGET)
		if [ ! -e $path ]; then
			_warn "$path does NOT exist"
			continue
		elif [ ! -e $parent ]; then
			#_warn "Parent Directory $parent does NOT exist"
			#continue
			mkdir -p $parent
		fi
		ln -sf $path $_TARGET
	done
	unset _TARGET path targets
}
_links() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/links/*\""
	fi
	local _LINK_FILE
	for _LINK_FILE in $(find patches -type f -path '*/*.patch/links/*' $variant_options | sort); do
		_link $_LINK_FILE
	done
}
