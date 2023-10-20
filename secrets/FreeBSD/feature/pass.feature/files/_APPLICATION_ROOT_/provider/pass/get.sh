_secrets_get_stdout() {
	pass show $_SECRET_KEY
}
_secrets_get_clipboard() {
	pass show --clip $_SECRET_KEY
}
