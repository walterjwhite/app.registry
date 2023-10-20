for _LOMBOK_FILE in $(find . -type f -name '*.java' -exec grep 'private static final Logger LOGGER = LoggerFactory.getLogger' -l {} +); do
	$_CONF_INSTALL_GNU_SED -i "s/^.*private static final Logger LOGGER = LoggerFactory.getLogger.*$//" $_LOMBOK_FILE
	$_CONF_INSTALL_GNU_SED -i '/public class/i @Slf4j' $_LOMBOK_FILE
	$_CONF_INSTALL_GNU_SED -i '/package/a import lombok.extern.slf4j.Slf4j;' $_LOMBOK_FILE
done
