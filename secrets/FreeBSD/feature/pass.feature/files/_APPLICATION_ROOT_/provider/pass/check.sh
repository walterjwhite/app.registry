_sed_safe() {
	printf '%s' $1 | sed -e "s/\//\\\\\//g"
}
_SECRETS_PASS_PATH_SED_SAFE=$(_sed_safe ~/.password-store)
find -s ~/.password-store -type f ! -path '*/.git/*' -name '*.gpg' |
	sed -e "s/$_SECRETS_PASS_PATH_SED_SAFE\///" -e 's/\.gpg$//' |
	xargs -L1 -P$_CONF_SECRETS_CHECK_PARALLELIZATION_COUNT _secrets_check
