mvn versions:set -DnewVersion=$_VERSION $_CONF_DEV_MAVEN_OPTIONS
gc -am "version bump - $_VERSION"
