_files() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/files/*\""
	fi
	find patches -type d -path '*/*.patch/files' $variant_options |
		sort |
		xargs -L 1 -I _PATH_ rsync -lmrt _PATH_/ /
}
