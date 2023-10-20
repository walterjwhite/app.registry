for d in $(for f in $(git status -s | awk {'print$2'}); do
	dirname $f
done | sort -ur); do
	cd $d
	while [ ! -e pom.xml ]; do
		if [ $PWD = "$_PARENT_PROJECT_DIRECTORY" ]; then
			cd $_PARENT_PROJECT_DIRECTORY
			break
		fi
		cd ..
	done
	_info "Building $(basename $PWD)"
	. $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/build/maven/build.sh
	_info "Please enter a commit message"
	read _commitMessage
	gcommit $_commitMessage
	exit $?
done
