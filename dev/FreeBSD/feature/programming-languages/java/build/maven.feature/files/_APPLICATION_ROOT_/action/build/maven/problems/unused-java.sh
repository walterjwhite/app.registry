find . -type f -name '*.java' ! -path '*/src/main/java/*' ! -path '*/src/test/java/*' ! -path '*/target/*'
for _PROJECT in $(find . -type f -name '*.java' -path '*/src/main/java/*' -path '*/src/test/java/*' |
	sed -e "s/\/src\/main\/java\/.*//g" | sort -u); do
	if [ ! -e $_PROJECT/pom.xml ]; then
		_warn "$_PROJECT/pom.xml does not exist"
	fi
done
