_dir_find() {
	shift

	find . -type d -depth 0 "$@"
}
