_git_find() {
	shift
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
	find $(git rev-parse --git-dir) -type d -depth 0 "$@"
}
