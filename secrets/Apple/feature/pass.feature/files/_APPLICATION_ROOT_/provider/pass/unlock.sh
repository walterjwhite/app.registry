cd ~/.password-store
_SECRET_KEY=$(. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/provider/$_CONF_SECRETS_PROVIDER/find.sh | head -1)
pass show $_SECRET_KEY >/dev/null 2>&1
