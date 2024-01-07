_groups_add() {
	. $1
	_detail " add group: $1 $groupName $gid"
	pw groupadd -n $groupName -g $gid
	unset groupName gid
}
_groups() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/*.group\""
	fi
	local _GROUP_PATH
	for _GROUP_PATH in $(find patches -type f -path '*/*.patch/*.group' $variant_options | sort); do
		_groups_add $_GROUP_PATH
	done
}
