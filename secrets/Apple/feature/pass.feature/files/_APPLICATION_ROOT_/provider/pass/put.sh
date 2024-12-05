[ "$_CONF_SECRETS_OVERWRITE_EXISTING" ] && _PASS_OPTIONS="$_PASS_OPTIONS -f"
yes "$_SECRET_VALUE" | pass insert $_SECRET_KEY && pass git push
