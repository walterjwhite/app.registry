_build_all() {
	for _ELEMENT in $@; do
		_build
	done
}
_build() {
	_COMMAND_DIRECTORY=$(readlink -f $_ELEMENT)
	_HAS_FILES=$(find $_COMMAND_DIRECTORY -maxdepth 1 -type f -name "*.go" -print -quit | wc -l)
	if [ "$_HAS_FILES" -eq "0" ]; then
		return
	fi
	cd $_COMMAND_DIRECTORY
	_info "Building $(basename $_COMMAND_DIRECTORY)"
	for _BUILD_EXECUTOR in $(find $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/go/lib -type f | sort -u); do
		. $_BUILD_EXECUTOR
	done
	cd $_PWD
}
_build_packages() {
	find . -type d \( ! -path '*/.git/*' -and ! -path '*/.archived/*' -and ! -path '*/.archived' \) | sort -u
}
_go_build_cleanup() {
	rm -rf /tmp/{go-build*,cgo*,cc*,golangci*}
}
_PWD=$PWD
_defer _go_build_cleanup
unset GOPATH
if [ "$#" -eq "0" ]; then
	_build_all $(_build_packages)
else
	_build_all $@
fi
_NO_EXEC=1
