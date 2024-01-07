_fstab() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/*.fstab\""
	fi
	local _FSTAB_PATH
	for _FSTAB_PATH in $(find patches -type f -path '*/*.patch/*.fstab' $variant_options | sort); do
		_PATCH_NAME=$(printf '%s' "$_FSTAB_PATH" | $_CONF_INSTALL_GNU_GREP -Po '^.*.\.patch' |
			sed -e "s/^\.\///" -e "s/\.patch$//" -e "s/^patches\///")
		printf '# %s\n' "$_PATCH_NAME" >>/etc/fstab
		cat $_FSTAB_PATH >>/etc/fstab
		printf '\n' >>/etc/fstab
	done
}
