_secrets_get_stdout() {
	pass show $_PASS_OPTIONS $_SECRET_KEY
}
_secrets_get_find() {
	if [ $# -eq 0 ]; then
		return 1
	fi
	local matched=$(. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/provider/$_CONF_SECRETS_PROVIDER/find.sh)
	local matches=$(printf '%s\n' $matched | wc -l)
	if [ -n "$matched" ] && [ $matches -eq 1 ]; then
		_SECRET_KEY=$matched
	fi
}
_secrets_get_clipboard() {
	_PASS_OPTIONS=--clip _secrets_get_stdout "$@"
}
