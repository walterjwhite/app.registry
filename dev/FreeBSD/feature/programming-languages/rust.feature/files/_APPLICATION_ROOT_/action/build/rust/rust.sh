_BUILD_FUNCTION=build
_NO_EXEC=1
find . -type f -name '*.rs' -maxdepth 1 -exec rustc {} \;
