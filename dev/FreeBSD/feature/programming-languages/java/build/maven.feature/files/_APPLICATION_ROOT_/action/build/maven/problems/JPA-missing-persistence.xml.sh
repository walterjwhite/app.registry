#[WARNING] diagnostic: warning: Unable to parse persistence.xml: Unable to perform unmarshalling at line number 0 and column 0. Message: null
for _PROJECT in $(find . -type f -name .jpa2 | sed -e "s/\.jpa2//"); do
	_PERSISTENCE_UNIT_XML=$_PROJECT/src/main/resources/META-INF/persistence.xml
	if [ ! -e $_PERSISTENCE_UNIT_XML ]; then
		_warn "missing: $_PERSISTENCE_UNIT_XML"
	fi
done
