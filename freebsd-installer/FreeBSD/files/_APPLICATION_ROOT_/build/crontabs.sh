#!/bin/sh
_do_crontabs() {
	_info "Writing $user crontab"
	local user_crontab=$(mktemp)
	printf '# disable mail\n' >>$user_crontab
	printf 'MAILTO=""\n\n' >>$user_crontab
	if [ "$user" = "root" ]; then
		printf 'PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin\n\n' >>$user_crontab
	else
		printf 'PATH=/usr/local/bin:/usr/bin:/bin:/opt/bin\n\n' >>$user_crontab
	fi
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/crontabs/$user\""
	fi
	local crontab_path
	for crontab_path in $(find patches -type f -path "*/*.patch/crontabs/$user/*" $variant_options); do
		printf '# %s\n' "$crontab_path" >>$user_crontab
		cat $crontab_path >>$user_crontab
	done
	crontab -f -r -u $user 2>/dev/null
	crontab -u $user $user_crontab
	rm -f $user_crontab
}
_crontabs() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/crontabs/*\""
	fi
	for user in $(basename $(find patches -type d -path '*/*.patch/crontabs/*' $variant_options) | sort -u); do
		_do_crontabs
	done
	unset user
}
