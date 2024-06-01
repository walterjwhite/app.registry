_sed_safe() {
	printf '%s' $1 | sed -e "s/\//\\\\\//g"
}
_SECRETS_PASS_PATH_SED_SAFE=$(_sed_safe ~/.password-store)
_SECRET_KEY=$(find ~/.password-store -type f ! -path '*/.git/*' -name '*.gpg' | sed -e "s/$_SECRETS_PASS_PATH_SED_SAFE\///" -e 's/\.gpg$//' | sort -u | head -1)
pass show $_SECRET_KEY >/dev/null 2>&1
