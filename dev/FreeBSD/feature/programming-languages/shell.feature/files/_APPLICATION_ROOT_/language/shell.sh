if [ $(find . -type f \( -name "*.sh" -or -path '*/bin/*' \) ! -path '*/node_modules/*' \
	! -path '*/target/*' \
	! -path '*/.idea/*' \
	! -path '*/.git/*' \
	-print -quit | wc -l) -eq 0 ]; then
	return 1
fi
_exec_all_sh() {
	find . -type f \( -name "*.sh" -or -path '*/bin/*' \) ! -path '*/node_modules/*' \
		! -path '*/target/*' \
		! -path '*/.idea/*' \
		! -path '*/.git/*' \
		-exec $_EXEC_CMD {} +
}
_EXEC_CMD="shfmt -w"
_EXEC_ALL_CMD=_exec_all_sh
return 0
