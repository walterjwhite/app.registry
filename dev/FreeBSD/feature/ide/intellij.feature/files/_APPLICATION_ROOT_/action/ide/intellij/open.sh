#https://www.jetbrains.com/help/idea/opening-files-from-command-line.html#db7435eb
case $_PLATFORM in
Apple)
	_CONF_DEV_INTELLIJ_IDE=/Applications/Intellij\ IDEA.app/Contents/MacOS/idea
	;;
FreeBSD)
	_CONF_DEV_INTELLIJ_IDE=/usr/local/share/intellij/bin/idea.sh
	;;
esac
JAVA_HOME=$_CONF_DEV_JAVA_IDE_JAVA_HOME $_CONF_DEV_INTELLIJ_IDE $_IDE_PROJECT >/dev/null 2>&1 &
