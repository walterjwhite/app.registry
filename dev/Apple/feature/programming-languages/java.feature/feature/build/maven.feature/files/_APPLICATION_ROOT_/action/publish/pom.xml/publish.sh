_NO_EXEC=1
_info "Packaging and Deploying artifacts"
mvn deploy -DstagingProfileId=$_CONF_DEV_DEPLOY_STAGING_PROFILE_ID $_CONF_DEV_PUBLISH_OPTIONS $@
