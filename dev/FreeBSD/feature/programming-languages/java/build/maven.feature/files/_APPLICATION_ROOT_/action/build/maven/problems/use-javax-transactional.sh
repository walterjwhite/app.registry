#sed -i "s/javax.transaction.Transactional/com.google.inject.persist.Transactional/" $(find . -type f | grep \\.java)
find . -type f -name '*.java' -exec $_CONF_INSTALL_GNU_SED -i "s/com.google.inject.persist.Transactional/javax.transaction.Transactional/" {} +
