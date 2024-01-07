_gpg_push_() {
	gpg –keyserver $1 –send-key _KEY_ID
}
_gpg_push_ mit.edu
_gpg_push_ pool.sks-keyservers.net
_gpg_push_ gnupg.net
_gpg_push_ keys.pgp.net
_gpg_push_ surfnet.nl
_gpg_push_ mit.edu
mvn javadoc:jar
mvn package deploy -DstagingProfileId=$_CONF_DEV_DEPLOY_STAGING_PROFILE_ID $_CONF_DEV_DEPLOY_OPTIONS $@
