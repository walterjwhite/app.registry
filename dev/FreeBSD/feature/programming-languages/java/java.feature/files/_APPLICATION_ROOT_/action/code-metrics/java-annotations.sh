find . -type f -name "*.java" ! -path '*/.git/*' ! -path '*/target/*' -exec $_CONF_INSTALL_GNU_GREP -Poh '@[\w]+' {} + |
	sort -u
