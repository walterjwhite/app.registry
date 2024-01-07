_nodejs_find() {
	shift

	find . -type d -name node_modules \
		! -path '*/target/*' \
		! -path '*/.idea/*' \
		! -path '*/.git/*' $@
}
