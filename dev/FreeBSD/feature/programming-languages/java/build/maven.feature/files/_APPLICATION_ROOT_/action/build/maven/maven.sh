_BUILD_FUNCTION=build
_NO_EXEC=1
_maven_exec() {
	_PARENT_PROJECT_DIRECTORY=$PWD
	for _ARG in "$@"; do
		_debug "$_ARG"
		case $_ARG in
		--changed)
			shift
			_BUILD_FUNCTION=build-changed
			;;
		--c)
			shift
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/clean.sh
			;;
		--u)
			shift
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/update.sh
			;;
		--problems)
			shift
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/problems.sh
			;;
		--deploy)
			shift
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/deploy.sh
			;;
		--version=*)
			_VERSION="$_KEY_SERVERS ${_ARG#*=}"
			shift
			. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/version.sh
			;;
		esac
	done
	. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/action/build/maven/${_BUILD_FUNCTION}.sh
	if [ $? -gt 0 ]; then
		_error "Error $_ACTION [$(basename $PWD)] ($_LANGUAGE)"
	fi
}
_maven_exec_recursive() {
	local _pwd=$PWD
	_detail "$_ACTION [$(basename $PWD) (recursive)] ($_LANGUAGE)"
	for _MAVEN_PROJECT in $(find . -type f -name pom.xml -maxdepth $_CONF_DEV_MAVEN_MAX_DEPTH ! -path '*/node_modules/*' | sed -e 's/\/pom.xml//'); do
		cd $_MAVEN_PROJECT
		if [ ! -e ../pom.xml ]; then
			_maven_exec "$@"
		else
			_warn "Not ${_BUILD_FUNCTION}ing child project $_MAVEN_PROJECT"
		fi
		cd $_pwd
	done
}
if [ -e pom.xml ]; then
	_maven_exec "$@"
else
	_maven_exec_recursive "$@"
fi
