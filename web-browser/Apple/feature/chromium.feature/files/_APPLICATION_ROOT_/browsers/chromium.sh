_download() {
	mkdir -p $_CONF_INSTALL_CACHE_PATH
	local _cached_filename
	if [ $# -gt 1 ]; then
		_cached_filename="$2"
	else
		_cached_filename=$(basename $1 | sed -e 's/?.*$//')
	fi
	_DOWNLOADED_FILE=$_CONF_INSTALL_CACHE_PATH/$_cached_filename
	if [ -e $_DOWNLOADED_FILE ]; then
		_detail "$1 already downloaded to: $_DOWNLOADED_FILE"
		return
	fi
	if [ -z "$_DOWNLOAD_DISABLED" ]; then
		_info "Downloading $1 -> $_DOWNLOADED_FILE"
		curl $_CURL_OPTIONS -o $_DOWNLOADED_FILE -s -L "$1"
	else
		_continue_if "Please manually download: $1 and place it in $_DOWNLOADED_FILE" "Y/n"
	fi
}
_download_install_file() {
	_require "$1" "1 (_download_install_file) target filename"
	_info "Installing $_DOWNLOADED_FILE -> $1"
	_sudo mkdir -p $(dirname $1)
	_sudo cp $_DOWNLOADED_FILE $1
	_sudo chmod 444 $1
	unset _DOWNLOADED_FILE
	[ ! -e $1 ] && return 1
	return 0
}
_verify() {
	[ -z "$_HASH_ALGORITHM" ] && _HASH_ALGORITHM=512
	shasum -a $_HASH_ALGORITHM -c $1 >/dev/null 2>&1
}
_extract() {
	if [ $# -lt 2 ]; then
		_warn "Expecting 2 arguments, source file, and target to extract to"
		return 1
	fi
	_info "### Extracting $1"
	local _extension=$(printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Po "\\.(tar\\.gz|tar\\.bz2|tbz2|tgz|zip|tar\\.xz)$")
	case $_extension in
	".tar.gz" | ".tgz")
		tar zxf $1 -C $2
		;;
	".zip")
		unzip -q $1 -d $2
		;;
	".tar.bz2" | ".tbz2")
		tar jxf $1 -C $2
		;;
	".tar.xz")
		xz -dc $1 | tar xf -C $2
		;;
	*)
		_warn "extension unsupported - $_extension $1"
		return 2
		;;
	esac
}
BROWSER_CMD=chrome
case $_PLATFORM in
Linux | FreeBSD)
	_CONFIGURATION_DIRECTORY=~/.config/chromium
	;;
*)
	_error "Unsupported platform: $_PLATFORM"
	;;
esac
_CONFIGURATION_DIRECTORY=~/.config/chromium
_browser_new_instance() {
	local chromium_instance_dir=$_INSTANCE_DIRECTORY/.config/chromium
	mkdir -p $chromium_instance_dir/Default
	if [ ! -e $_CONFIGURATION_DIRECTORY/Default/Preferences ]; then
		_error "$_CONFIGURATION_DIRECTORY/Default/Preferences does not exist" 1
	fi
	cp -R $_CONFIGURATION_DIRECTORY/Default/Preferences "$chromium_instance_dir/Default/"
	cp -R $_CONFIGURATION_DIRECTORY/Default/Extensions "$chromium_instance_dir/Default/" 2>/dev/null
	_info "Updating conf to use new instance dir"
	local home_directory_sed_safe=$(_sed_safe $HOME)
	local instance_dir_sed_safe=$(_sed_safe $chromium_instance_dir)
	find $_INSTANCE_DIRECTORY -type f ! -name '*.sqlite' -exec $_CONF_INSTALL_GNU_SED -i "s/$home_directory_sed_safe/$instance_dir_sed_safe/g" {} +
	mkdir -p $_INSTANCE_DIRECTORY/Downloads
	_SQLITE_DATABASE=$chromium_instance_dir/Default/History
	_QUERY="SELECT url,ROUND(LAST_VISIT_TIME/1000000) FROM urls WHERE url NOT LIKE 'chrome-extension://%' ORDER BY last_visit_time DESC"
	_browser_extensions
	[ -n "$_BROWSER_EXTENSIONS" ] && _browser_add_args "--load-extension=$_BROWSER_EXTENSIONS"
}
_browser_remote_debug() {
	local remote_debug
	if [ $_WEB_BROWSER_REMOTE_DEBUG -gt 0 ]; then
		remote_debug="=$_WEB_BROWSER_REMOTE_DEBUG"
	fi
	_browser_add_args "--remote-debugging-port${remote_debug}"
	[ "$_WEB_BROWSER_HEADLESS" ] && _browser_add_args --headless
}
_browser_private_window() {
	_browser_add_args --incognito
}
_browser_http_proxy() {
	_browser_add_args "--proxy-server=http://${_WEB_BROWSER_HTTP_PROXY}"
}
_browser_socks_proxy() {
	_browser_add_args "--proxy-server=socks${_CONF_WEB_BROWSER_SOCKS_PROXY_VERSION}://$_WEB_BROWSER_SOCKS_PROXY"
}
_browser_extensions() {
	local extension_config extension_name extension_version
	for extension_config in $(cat $_CONFIGURATION_DIRECTORY/extensions); do
		_browser_extension $extension_config
	done
}
_browser_extension() {
	extension_name=${1%%:*}
	extension_version=${1#*:}
	case $extension_name in
	ublock-origin)
		_browser_extension_load https://github.com/gorhill/uBlock/releases/download/${extension_version}/uBlock0_${extension_version}.chromium.zip $extension_name $extension_version
		mv $_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name/uBlock0.chromium/* $_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name
		rm -rf $_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name/uBlock0.chromium
		;;
	Browserpass)
		_browser_extension_load https://github.com/browserpass/browserpass-extension/releases/download/${extension_version}/browserpass-github-${extension_version}.crx $extension_name $extension_version
		;;
	Ghostery)
		_browser_extension_load https://github.com/ghostery/ghostery-extension/releases/download/v${extension_version}/ghostery-chrome-v${extension_version}.zip $extension_name $extension_version
		;;
	*)
		_warn "Unsupported extension: $extension_name"
		continue
		;;
	esac
}
_browser_extension_load() {
	_browser_extension_download_extract $1 $2 $3 || {
		browser_extension_delete=1 _browser_extension_download_extract $1 $2 $3 || return 1
	}
	if [ -z "$_BROWSER_EXTENSIONS" ]; then
		_BROWSER_EXTENSIONS="$_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name"
	else
		_BROWSER_EXTENSIONS="$_BROWSER_EXTENSIONS,$_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name"
	fi
}
_browser_extension_download_extract() {
	[ "$browser_extension_delete" ] && rm -f $_CONF_INSTALL_CACHE_PATH/$extension_name-$extension_version.crx.zip
	_download $1 ${2}-$3.crx.zip
	_extract $_CONF_INSTALL_CACHE_PATH/$extension_name-$extension_version.crx.zip $_INSTANCE_DIRECTORY/unpacked-extensions/$extension_name
}
