if [ $(find . -type f -name '*.rs' -maxdepth 1 -print -quit | wc -l) -eq 0 ]; then
	return 1
fi
