[ "$_CONF_SECRETS_OVERWRITE_EXISTING" ] && _PASS_OPTIONS="$_PASS_OPTIONS -f"
_ESCAPED_SECRET_VALUE=$(printf '%s' "$_SECRET_VALUE" | sed -e 's/"/\"/g' -e 's/!/\!/g')
yes "$_SECRET_VALUE" | pass insert $_SECRET_KEY && pass git push
