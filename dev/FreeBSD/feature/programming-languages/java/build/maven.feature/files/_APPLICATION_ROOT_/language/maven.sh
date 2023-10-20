_maven_has_child_modules() {
	if [ $(find . -type f -name pom.xml -print -quit | wc -l) -gt 1 ]; then
		return 0
	fi
	return 1
}
_require "$_CONF_DEV_MAVEN_MAX_DEPTH" _CONF_DEV_MAVEN_MAX_DEPTH
if [ $(find . -type f -name pom.xml -maxdepth $_CONF_DEV_MAVEN_MAX_DEPTH ! -path '*/node_modules/*' -print -quit | wc -l) -eq 0 ]; then
	return 1
fi
for _PROJECT_POM in $(find . -type f -name pom.xml ! -path '*/node_modules/*' -exec grep -l "<packaging>jar</packaging>" {} +); do
	mkdir -p $(dirname $_PROJECT_POM)/src/test/java
done
