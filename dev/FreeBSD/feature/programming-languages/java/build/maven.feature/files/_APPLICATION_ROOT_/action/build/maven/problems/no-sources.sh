_make_placeholder() {
	_warn "$1"
	mkdir -p $_java_directory/
	touch $_java_directory/PLACEHOLDER.java
}
for _PROJECT in $(find . -type f -name pom.xml -exec grep -l "<packaging>jar</packaging>" {} + | sed -e "s/\/pom.xml//"); do
	_java_directory=$_PROJECT/src/main/java
	if [ -e $_java_directory ]; then
		_java_file_count=$(find $_java_directory -type f -name '*.java' | wc -l)
		if [ "$_java_file_count" -eq "0" ]; then
			_make_placeholder "Project $_PROJECT is a JAR project, but has no Java files"
		fi
	else
		_make_placeholder "Project $_PROJECT is a JAR project, but has no source directory"
	fi
done
