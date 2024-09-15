_sed_safe() {
	printf '%s' $1 | sed -e "s/\//\\\\\//g"
}
_SECRETS_GPG_PATH=$_CONF_INSTALL_APPLICATION_DATA_PATH/gpg
_SECRETS_GPG_PATH_SED_SAFE=$(_sed_safe $_SECRETS_GPG_PATH)
mkdir -p $_SECRETS_GPG_PATH
cd $_SECRETS_GPG_PATH
[ ! -e .git ] && {
	git init
	_warn 'Add a remote to sync secrets'
}
[ "$_CONF_SECRETS_OVERWRITE_EXISTING" ] && [ -e $_SECRET_KEY.gpg ] && rm -f $_SECRET_KEY.gpg
mkdir -p $(dirname $_SECRET_KEY)
_PLAINTEXT=$(_mktemp)
printf '%s\n' "$_SECRET_VALUE" >>$_PLAINTEXT
gpg --output $_SECRET_KEY.gpg --encrypt --recipient $_FEATURE_GPG_USER_EMAIL $_PLAINTEXT
rm -f $_PLAINTEXT
unset _PLAINTEXT
git add $_SECRET_KEY.gpg
git commit $_SECRET_KEY.gpg -m "$_SECRET_KEY"
git push
