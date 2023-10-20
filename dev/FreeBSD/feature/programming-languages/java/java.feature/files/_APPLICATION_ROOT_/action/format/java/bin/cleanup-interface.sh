#!/bin/sh
set -a
_APPLICATION_NAME='dev'
_PLATFORM="FreeBSD"
_TAR_ARGS=" -f - "
_SUDO_CMD="sudo"
_ARCHITECTURE=$(uname -m)
_INSTALL_INSTALLER=pkg
: ${_CONF_INSTALL_GNU_GREP:=/usr/local/bin/grep}
: ${_CONF_INSTALL_GNU_SED:=gsed}
_PLATFORM_PACKAGES="git gsed gnugrep gtar gawk"
_NPM_PACKAGE="npm"
_RUST_PACKAGE="rust"
_PYPI_DISABLED=1
_PYPI_PACKAGE="python39 py39-pip"
_GO_PACKAGE="go"
GOPATH=/usr/local
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
if [ "$HOME" = "/" ]; then
	HOME=/root
fi
: ${_CONF_INSTALL_C_ALRT:="1;31m"}
: ${_CONF_INSTALL_C_ERR:="1;31m"}
: ${_CONF_INSTALL_C_SCS:="1;32m"}
: ${_CONF_INSTALL_C_WRN:="1;33m"}
: ${_CONF_INSTALL_C_INFO:="1;36m"}
: ${_CONF_INSTALL_C_DETAIL:="1;0;36m"}
: ${_CONF_INSTALL_C_DEBUG:="1;35m"}
: ${_CONF_INSTALL_C_STDIN:="1;34m"}
: ${_CONF_INSTALL_AUDIT:=0}
: ${_CONF_INSTALL_LOG_LEVEL:=2}
: ${_CONF_INSTALL_DATE_FORMAT:="%Y/%m/%d|%H:%M:%S"}
: ${_CONF_INSTALL_DATE_TIME_FORMAT:="%Y/%m/%d %H:%M:%S"}
: ${_CONF_INSTALL_WAIT_INTERVAL:=30}
: ${_CONF_INSTALL_NO_PAGER:=0}
: ${_CONF_INSTALL_BEEP_TIMEOUT:=5}
: ${_CONF_INSTALL_BEEP_ERR:='L32c'}
: ${_CONF_INSTALL_BEEP_ALRT:='L32f'}
: ${_CONF_INSTALL_BEEP_SCS:='L32a'}
: ${_CONF_INSTALL_BEEP_WRN:=''}
: ${_CONF_INSTALL_BEEP_INFO:=''}
: ${_CONF_INSTALL_BEEP_DETAIL:=''}
: ${_CONF_INSTALL_BEEP_DEBUG:=''}
: ${_CONF_INSTALL_BEEP_STDIN:='L32ab'}
: ${_CONF_INSTALL_SYSTEM_TEMPLATE_PATH:=/usr/share/git/templates}
: ${_CONF_INSTALL_LIBRARY_PATH:=/usr/local/walterjwhite}
: ${_CONF_INSTALL_BIN_PATH:=/usr/local/bin}
: ${_CONF_INSTALL_CONTEXT:=$_CONSOLE_CONTEXT_ID}
: ${_CONF_INSTALL_CONTEXT:=default}
: ${_CONF_INSTALL_DATA_PATH:=$HOME/.data}
: ${_CONF_INSTALL_CACHE_PATH:=$_CONF_INSTALL_DATA_PATH/.cache}
: ${_CONF_INSTALL_CONFIG_PATH:=$HOME/.config/walterjwhite}
: ${_CONF_INSTALL_STEP_TIMEOUT:=300}
: ${_CONF_INSTALL_CONF_VALIDATION_FUNCTION:=_warn}
: ${_CONF_INSTALL_INDENT:="  "}
: ${_CONF_INSTALL_FEATURE_TIMEOUT_ERROR_LEVEL:=warn}
case $(ps -o stat= -p $$) in
*+*) ;;
*)
	_BACKGROUNDED=1
	;;
esac
if [ -z "$_NON_INTERACTIVE" ]; then
	tty >/dev/null || _NON_INTERACTIVE=0
fi
if ! (: >&7) 2>/dev/null; then
	exec 7>&1
	exec 8>&2
fi
if [ $_NON_INTERACTIVE ]; then
	_LOG_TARGET=7
	_NLOG_TARGET=1
else
	_LOG_TARGET=8
	_NLOG_TARGET=2
fi
: ${_CONF_INSTALL_WAITER_LEVEL:=_debug}
: ${_CONF_INSTALL_IOSTAT_DURATION:=5}
which pgrep >/dev/null 2>&1 && _PARENT_PROCESSES_FUNCTION=_parent_processes_pgrep
_DETECTED_PLATFORM=$(uname)
case $_DETECTED_PLATFORM in
Darwin)
	_DETECTED_PLATFORM=Apple
	;;
esac
: ${_CONF_INSTALL_REPOSITORY_URL:=https://github.com/walterjwhite}
: ${_CONF_INSTALL_MIRROR_URLS:=https://github.com/walterjwhite}
: ${_CONF_INSTALL_SUDO_TIMEOUT:=270}
: ${_CONF_INSTALL_NETWORK_TEST_TARGET:=google.com}
: ${_CONF_INSTALL_NETWORK_TEST_TIMEOUT:=5}
: ${_CONF_INSTALL_TEAMS_MESSAGE_PARALLELIZATION:=5}
: ${_CONF_INSTALL_PARALLEL_BUILD:=8}
: ${_CONF_INSTALL_APP_REGISTRY_GIT_URL:=github.com/walterjwhite/app.registry.git}
: ${_CONF_INSTALL_RUN_PATH:=/tmp/$USER/walterjwhite/app}
_CONF_INSTALL_DATA_ARTIFACTS_PATH=$_CONF_INSTALL_DATA_PATH/install/artifacts
_CONF_INSTALL_DATA_REGISTRY_PATH=$_CONF_INSTALL_DATA_PATH/install/registry
_CONF_INSTALL_APPLICATION_DATA_PATH=$_CONF_INSTALL_DATA_PATH/$_APPLICATION_NAME
_CONF_INSTALL_APPLICATION_CONFIG_PATH=$_CONF_INSTALL_CONFIG_PATH/$_APPLICATION_NAME
_CONF_INSTALL_APPLICATION_LIBRARY_PATH=$_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME
: ${_CONF_DEV_VSCODE_IDE:=/usr/local/bin/vscode}
: ${_CONF_DEV_SSH_KEYTYPE:=ecdsa}
: ${_CONF_DEV_LOMBOK_SLF4J_LOGGER_NAME:=LOGGER}
_beep() {
	if [ -n "$_BEEPING" ]; then
		_debug "Another 'beep' is in progress"
		return
	fi
	_BEEPING=1
	_do_beep "$@" &
}
_do_beep() {
	if [ -e /dev/speaker ]; then
		printf '%s' "$1" >/dev/speaker
	fi
	_beep_done
}
_beep_done() {
	unset _BEEPING
}
_mktemp() {
	mktemp -t ${_APPLICATION_NAME}.${_APPLICATION_CMD}.$1
}
_notify() {
	local title=$1
	local message=$2
	zenity --info --text="$_APPLICATION_NAME - $_APPLICATION_CMD - $title\n$message"
}
_open() {
	xdg-open $1
	sleep 1
}
_syslog() {
	logger -i -t "$_APPLICATION_NAME.$_APPLICATION_CMD" "$1"
}
_get_defaults() {
	local app_name=$(printf "$_TARGET_APPLICATION_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
	find all/defaults $_PLATFORM/defaults -type f \
		-exec $_CONF_INSTALL_GNU_GREP -Poh "_CONF_${app_name}_[\w_\d]{3,}" {} + 2>/dev/null | sort -u
}
_variable_is_set() {
	if [ $(env | grep "^$1=.*$" | wc -l) -gt 0 ]; then
		return 0
	fi
	return 1
}
_has_required_conf() {
	if [ -n "$_REQUIRED_APP_CONF" ]; then
		for _REQUIRED_APP_CONF_ITEM in $(printf '%s' "$_REQUIRED_APP_CONF" | sed -e 's/$/\n/' | tr '|' '\n'); do
			_variable_is_set $_REQUIRED_APP_CONF_ITEM || {
				_warn "$_REQUIRED_APP_CONF_ITEM is unset"
				_MISSING_REQUIRED_CONF=1
			}
		done
		if [ -n "$_MISSING_REQUIRED_CONF" ]; then
			_error "Required configuration is missing, please refer to above error(s)"
		fi
	fi
}
_environment_filter() {
	grep '^_CONF_'
}
_environment_dump() {
	if [ -z "$_APPLICATION_PIPE_DIR" ]; then
		return
	fi
	if [ -z "$_ENVIRONMENT_FILE" ]; then
		_ENVIRONMENT_FILE=$_APPLICATION_PIPE_DIR/environment
	fi
	mkdir -p $(dirname $_ENVIRONMENT_FILE)
	env | _environment_filter | sort -u | grep -v '^$' | sed -e 's/=/="/' -e 's/$/"/' >>$_ENVIRONMENT_FILE
}
_environment_load() {
	if [ -n "$_ENVIRONMENT_FILE" ]; then
		if [ -e "$_ENVIRONMENT_FILE" ]; then
			. $_ENVIRONMENT_FILE 2>/dev/null
		else
			_warn "$_ENVIRONMENT_FILE does not exist!"
		fi
	fi
}
_is_feature() {
	printf '%s' $_SETUP | grep -c /feature/
}
_disable_feature() {
	if [ -z "$_FEATURE_DISABLED" ]; then
		_warn "Error installing feature: $_FEATURE ($1)"
	fi

	printf '%s\n' $(_feature_key $1)_DISABLED=1 | _metadata_write
}
_is_feature_enabled() {
	local _feature_key=$(_feature_key $1)
	if [ $(env | grep -c "^${_feature_key}_DISABLED=1$") -gt 0 ]; then
		_warn "$1 is disabled"
		return 1
	fi
	return 0
}
_feature_key() {
	printf '%s\n' "_FEATURE_${1}" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}
_call() {
	local _function_name=$1
	shift
	type $_function_name >/dev/null 2>&1
	local _return=$?
	if [ $_return -gt 0 ]; then
		_debug "${_function_name} does not exist"
		return $_return
	fi
	$_function_name "$@"
}
_require() {
	local level=error
	if [ -z "$1" ]; then
		if [ -n "$_WARN" ]; then
			level=warn
		fi
		_$level "$2 required $_REQUIRE_DETAILED_MESSAGE" $3
		return 1
	fi
	unset _REQUIRE_DETAILED_MESSAGE
}
_read_if() {
	if [ $(env | grep -c "^$2=.*") -eq 1 ]; then
		_debug "$2 is already set"
		return 1
	fi
	[ $_NON_INTERACTIVE ] && _error "Running in non-interactive mode and user input was requested: $@" 10
	_print_log 9 STDI "$_CONF_INSTALL_C_STDIN" "$_CONF_INSTALL_BEEP_STDIN" "$1 $3"
	read -r $2
}
_read_ifs() {
	stty -echo
	_read_if "$@"
	stty echo
}
_continue_if() {
	_read_if "$1" _PROCEED "$2"
	if [ -z "$_PROCEED" ]; then
		_DEFAULT=$(printf '%s' $2 | awk -F'/' {'print$1'})
		_PROCEED=$_DEFAULT
	fi
	_PROCEED=$(printf '%s' "$_PROCEED" | tr '[:lower:]' '[:upper:]')
	if [ $_PROCEED = "N" ]; then
		return 1
	fi
	return 0
}
_() {
	local _successfulExitStatus=0
	if [ -n "$_SUCCESSFUL_EXIT_STATUS" ]; then
		_successfulExitStatus=$_SUCCESSFUL_EXIT_STATUS
		unset _SUCCESSFUL_EXIT_STATUS
	fi
	_info "## $*"
	if [ -z "$_DRY_RUN" ]; then
		"$@"
		local _exit_status=$?
		if [ $_exit_status -ne $_successfulExitStatus ]; then
			if [ -n "$_ON_FAILURE" ]; then
				$_ON_FAILURE
				return
			fi
			if [ -z "$_WARN_ON_ERROR" ]; then
				_error "Previous cmd failed" $_exit_status
			else
				unset _WARN_ON_ERROR
				_warn "Previous cmd failed - $* - $_exit_status"
				_ENVIRONMENT_FILE=$(mktemp -t error) _environment_dump
				return $_exit_status
			fi
		fi
	fi
}
_optional_include() {
	if [ -e $1 ]; then
		. $1
	else
		_debug "_optional_include: $1 does NOT exist"
	fi
}
_configure() {
	_optional_include $1
}
_error() {
	if [ $# -ge 2 ]; then
		_EXIT_STATUS=$2
	else
		_EXIT_STATUS=1
	fi
	_EXIT_LOG_LEVEL=4
	_EXIT_STATUS_CODE="ERR"
	_EXIT_COLOR_CODE="$_CONF_INSTALL_C_ERR"
	_EXIT_BEEP="$_CONF_INSTALL_BEEP_ERR"
	_EXIT_MESSAGE="$1 ($_EXIT_STATUS)"
	_defer _environment_dump
	exit $_EXIT_STATUS
}
_success() {
	_EXIT_STATUS=0
	_EXIT_LOG_LEVEL=3
	_EXIT_STATUS_CODE="SCS"
	_EXIT_COLOR_CODE="$_CONF_INSTALL_C_SCS"
	_EXIT_BEEP="$_CONF_INSTALL_BEEP_SCS"
	_EXIT_MESSAGE="$1"
	exit 0
}
_contains_argument() {
	local _key=$1
	shift
	for _ARG in "$@"; do
		case $_ARG in
		$_key)
			return 0
			;;
		esac
	done
	return 1
}
_write() {
	if [ -z "$1" ]; then
		_error "filename cannot be empty."
	fi
	$_SUDO_CMD mkdir -p $(dirname "$1")
	$_SUDO_CMD tee -a "$1" >/dev/null
}
_print_help() {
	if [ -e $2 ]; then
		_info "$1:"
		cat $2
		printf '\n'
	fi
}
_print_help_and_exit() {
	_print_help 'system-wide options' $_CONF_INSTALL_LIBRARY_PATH/install/help/default
	if [ "$_APPLICATION_NAME" != "install" ]; then
		_print_help $_APPLICATION_NAME $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME/help/default
		_print_help "$_APPLICATION_NAME/$_APPLICATION_CMD" $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME/help/$_APPLICATION_CMD
	fi
	exit 0
}
_init_logging() {
	unset _LOGFILE
	case $_CONF_INSTALL_LOG_LEVEL in
	0)
		local logfile=$(_mktemp debug)
		_warn "Writing debug contents to: $logfile"
		_set_logfile "$logfile"
		set -x
		;;
	esac
}
_set_logfile() {
	if [ -n "$1" ]; then
		_LOGFILE=$1
		mkdir -p $(dirname $1)
		exec >>$1
		exec 2>>$1
	fi
}
_reset_logging() {
	exec >&7
	exec 2>&8
}
_alert() {
	_print_log 5 ALRT "$_CONF_INSTALL_C_ALRT" "$_CONF_INSTALL_BEEP_ALRT" "$1"
	local recipients="$_OPTN_INSTALL_ALERT_RECIPIENTS"
	local subject="Alert: $0 - $1"
	if [ -z "$recipients" ]; then
		_warn "recipients is empty, aborting"
		return 1
	fi
	_mail "$recipients" "$subject" "$2"
}
_warn() {
	_print_log 3 WRN "$_CONF_INSTALL_C_WRN" "$_CONF_INSTALL_BEEP_WRN" "$1"
}
_info() {
	_print_log 2 INF "$_CONF_INSTALL_C_INFO" "$_CONF_INSTALL_BEEP_INFO" "$1"
}
_detail() {
	_print_log 2 DTL "$_CONF_INSTALL_C_DETAIL" "$_CONF_INSTALL_BEEP_DETAIL" "$1"
}
_debug() {
	_print_log 1 DBG "$_CONF_INSTALL_C_DEBUG" "$_CONF_INSTALL_BEEP_DEBUG" "$1"
}
_do_log() {
	:
}
_colorize_text() {
	printf '\033[%s%s\033[0m' "$1" "$2"
}
_sed_remove_nonprintable_characters() {
	sed -e 's/[^[:print:]]//g'
}
_print_log() {
	if [ -z "$5" ]; then
		if test ! -t 0; then
			cat - | _sed_remove_nonprintable_characters |
				while read _line; do
					_print_log $1 $2 $3 $4 "$_line"
				done
			return
		fi
		return
	fi
	local _level=$1
	local _slevel=$2
	local _color=$3
	local _tone=$4
	local _message="$5"
	if [ $_level -lt $_CONF_INSTALL_LOG_LEVEL ]; then
		return
	fi
	[ -n "$_LOGGING_CONTEXT" ] && _message="$_LOGGING_CONTEXT - ${_LOG_INDENT}$_message"
	local _message_date_time=$(date +"$_CONF_INSTALL_DATE_FORMAT")
	if [ $_BACKGROUNDED ] && [ $_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD ]; then
		$_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD "$_slevel" "$_message" &
	fi
	_do_log "$_level" "$_slevel" "$_message"
	[ -n "$_tone" ] && _beep "$_tone"
	_log_non_interactive "$_slevel" "$_message_date_time" "${_LOG_INDENT}$_message"
	_log_interactive "$_color" "$_slevel" "$_message_date_time" "${_LOG_INDENT}$_message"
}
_add_logging_context() {
	if [ -z "$1" ]; then
		return 1
	fi
	if [ -z "$_LOGGING_CONTEXT" ]; then
		_LOGGING_CONTEXT="$1"
		return
	fi
	_LOGGING_CONTEXT="$_LOGGING_CONTEXT.$1"
}
_remove_logging_context() {
	if [ -z "$_LOGGING_CONTEXT" ]; then
		return 1
	fi
	case $_LOGGING_CONTEXT in
	*.*)
		_LOGGING_CONTEXT=$(printf '%s' "$_LOGGING_CONTEXT" | sed 's/\.[a-z0-9 _-]*$//')
		;;
	*)
		unset _LOGGING_CONTEXT
		;;
	esac
}
_increase_indent() {
	_LOG_INDENT="$_LOG_INDENT${_CONF_INSTALL_INDENT}"
}
_decrease_indent() {
	_LOG_INDENT=$(printf '%s' "$_LOG_INDENT" | sed -e "s/${_CONF_INSTALL_INDENT}$//")
	if [ ${#_LOG_INDENT} -eq 0 ]; then
		unset _LOG_INDENT
	fi
}
_reset_indent() {
	unset _LOG_INDENT
}
_log_non_interactive() {
	if [ $_NON_INTERACTIVE ] || [ $_LOGFILE ]; then
		if [ $_CONF_INSTALL_AUDIT -gt 0 ]; then
			printf >&$_NLOG_TARGET '%s %s %s\n' "$1" "$2" "$3"
		else
			printf >&$_NLOG_TARGET '%s\n' "$3"
		fi
		_syslog "$3"
	fi
}
_log_interactive() {
	[ $_NO_WRITE_STDERR ] && return
	_is_open $_LOG_TARGET || return
	if [ $_NON_INTERACTIVE ] && [ -z $_LOGFILE ]; then
		return
	fi
	if [ $_CONF_INSTALL_AUDIT -gt 0 ]; then
		printf >&$_LOG_TARGET '\033[%s%s \033[0m%s %s\n' "$1" "$2" "$3" "$4"
	else
		printf >&$_LOG_TARGET '\033[%s%s \033[0m\n' "$1" "$4"
	fi
}
_is_open() {
	(: >&"$1") 2>/dev/null
}
_log_app_init() {
	_log_level=debug
	[ $_NON_INTERACTIVE ] && {
		if [ $(basename $0 | grep -c '^_') -eq 0 ]; then
			_log_level=info
		fi
	}
	_log_app init
}
_log_app() {
	_$_log_level "$_APPLICATION_NAME:$_APPLICATION_CMD:$_APPLICATION_VERSION $_APPLICATION_BUILD_DATE / $_APPLICATION_INSTALL_DATE - $1 ($$)"
}
_syslog() {
	:
}
_mail() {
	if [ $# -lt 3 ]; then
		_warn "recipients[0], subject[1], message[2] is required - $# arguments provided"
		return 1
	fi
	local recipients=$(printf '%s' "$1" | tr '|' ' ')
	shift
	local subject="$1"
	shift
	local message="$1"
	shift
	printf "$message" | mail -s "$subject" $recipients
}
_on_exit() {
	[ $_EXIT ] && return 1
	_EXIT=0
	if [ -n "$_DEFERS" ]; then
		for _DEFER in $_DEFERS; do
			_call $_DEFER
		done
		unset _DEFERS
	fi
	_waitee_done
	if [ $_EXIT_STATUS -gt 0 ]; then
		_log_level=warn
	else
		_log_level=debug
	fi
	[ "$_EXIT_MESSAGE" ] && _print_log $_EXIT_LOG_LEVEL "$_EXIT_STATUS_CODE" "$_EXIT_COLOR_CODE" "$_EXIT_BEEP" "$_EXIT_MESSAGE"
	_log_app "exit"
	_on_exit_beep
}
_defer() {
	_DEFERS="${_DEFERS:+$_DEFERS }$1"
}
_on_exit_beep() {
	local current_time=$(date +%s)
	local timeout=$(($current_time + $_CONF_INSTALL_BEEP_TIMEOUT))
	if [ $current_time -le $timeout ]; then
		return 1
	fi
	local beep_code
	if [ $_EXIT_STATUS -gt 0 ]; then
		beep_code="$_CONF_INSTALL_BEEP_ERR"
	else
		beep_code="$_CONF_INSTALL_BEEP_SCS"
	fi
	_beep "$beep_code" &
}
_context_id_is_valid() {
	printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Pq '^[a-zA-Z0-9_+-]+$' || _error "Context ID *MUST* only contain alphanumeric characters and +-: '^[a-zA-Z0-9_+-]+$'"
}
_init_application_context() {
	if [ -z "$_CONTEXT_VALIDATED" ]; then
		_context_id_is_valid "$_CONF_INSTALL_CONTEXT"
		_CONTEXT_VALIDATED=0
	fi
	_APPLICATION_CONTEXT_GROUP=$_CONF_INSTALL_RUN_PATH/$_CONF_INSTALL_CONTEXT
	_APPLICATION_CMD_DIR=$_APPLICATION_CONTEXT_GROUP/$_APPLICATION_NAME/$_APPLICATION_CMD
	_APPLICATION_PIPE=$_APPLICATION_CMD_DIR/$$
	_APPLICATION_PIPE_DIR=$(dirname $_APPLICATION_PIPE)
	mkdir -p $_APPLICATION_PIPE_DIR
	mkfifo $_APPLICATION_PIPE
	if [ "$_APPLICATION_NAME" != "install" ]; then
		_configure $_CONF_INSTALL_CONFIG_PATH/install
	fi
	_configure $_CONF_INSTALL_APPLICATION_CONFIG_PATH
	if [ -n "$_CONFIGURATIONS" ]; then
		local configure
		for configure in $_CONFIGURATIONS; do
			_configure $_CONF_INSTALL_CONFIG_PATH/$configure
		done
	fi
	$_CONF_INSTALL_WAITER_LEVEL "($_APPLICATION_CMD) Please use -w=$$"
}
_has_other_instances() {
	if [ $(find $_APPLICATION_CMD_DIR -type p -maxdepth 1 ! -name $$ | wc -l) -gt 0 ]; then
		return 0
	fi
	return 1
}
_waitee_done() {
	if [ -z "$_EXIT_STATUS" ]; then
		_EXIT_STATUS=0
	fi
	if [ -n "$_WAITEE" ] && [ -e $_APPLICATION_PIPE ]; then
		_info "$0 process completed, notifying ($_EXIT_STATUS)"
		printf '%s\n' "$_EXIT_STATUS" >$_APPLICATION_PIPE
		_info "$0 downstream process picked up"
	fi
	rm -f $_APPLICATION_PIPE
}
_waiter() {
	if [ -n "$_WAITER_PID" ]; then
		_UPSTREAM_APPLICATION_PIPE=$(find $_APPLICATION_CONTEXT_GROUP -type p -name $_WAITER_PID 2>/dev/null | head -1)
		if [ -z "$_UPSTREAM_APPLICATION_PIPE" ]; then
			_error "$_WAITER_PID not found"
		fi
		if [ ! -e $_UPSTREAM_APPLICATION_PIPE ]; then
			_warn "$_UPSTREAM_APPLICATION_PIPE does not exist, did upstream start?"
			return
		fi
		_info "Waiting for upstream to complete: $_WAITER_PID"
		while [ 1 ]; do
			if [ ! -e $_UPSTREAM_APPLICATION_PIPE ]; then
				_error "Upstream pipe no longer exists"
			fi
			_UPSTREAM_APPLICATION_STATUS=$(timeout $_CONF_INSTALL_WAIT_INTERVAL cat $_UPSTREAM_APPLICATION_PIPE 2>/dev/null)
			local _UPSTREAM_STATUS=$?
			if [ $_UPSTREAM_STATUS -eq 0 ]; then
				if [ -z "$_UPSTREAM_APPLICATION_STATUS" ] || [ $_UPSTREAM_APPLICATION_STATUS -gt 0 ]; then
					_error "Upstream exited with error ($_UPSTREAM_APPLICATION_STATUS)"
				fi
				_warn "Upstream finished: $_UPSTREAM_APPLICATION_PIPE ($_UPSTREAM_STATUS)"
				break
			fi
			_detail " Upstream is still running: $_UPSTREAM_APPLICATION_PIPE ($_UPSTREAM_STATUS)"
		done
	fi
}
_kill_all() {
	_do_kill_all $_APPLICATION_PIPE_DIR
}
_kill_all_group() {
	_do_kill_all $_APPLICATION_CONTEXT_GROUP
}
_do_kill_all() {
	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_kill $(basename $_EXISTING_APPLICATION_PIPE)
	done
}
_kill() {
	_warn "Killing $1"
	kill -TERM $1
}
_list() {
	_list_pid_infos $_APPLICATION_PIPE_DIR
}
_list_group() {
	_list_pid_infos $_APPLICATION_CONTEXT_GROUP
}
_list_pid_infos() {
	_info "Running processes:"
	_EXECUTABLE_NAME_SED_SAFE=$(_sed_safe $0)
	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_list_pid_info
	done
}
_list_pid_info() {
	_TARGET_PID=$(basename $_EXISTING_APPLICATION_PIPE)
	_TARGET_PS_DTL=$(ps -o command -p $_TARGET_PID | sed 1d | sed -e "s/^.*$_EXECUTABLE_NAME_SED_SAFE/$_EXECUTABLE_NAME_SED_SAFE/")
	_info " $_TARGET_PID - $_TARGET_PS_DTL"
}
_parent_processes() {
	[ -n "$_PARENT_PROCESSES_FUNCTION" ] && $_PARENT_PROCESSES_FUNCTION
}
_parent_processes_pgrep() {
	pgrep -P $1
}
_init_pager() {
	if [ "$_CONF_INSTALL_NO_PAGER" = "1" ]; then
		PAGER=cat
	fi
}
for _JAVA_INTERFACE in $(grep -l '^public interface ' $@); do
	. $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME
	case $_DETECTED_PLATFORM in
	$_PLATFORM) ;;
	Darwin | FreeBSD | Linux | MINGW64_NT-*)
		_error "Please use the appropriate platform-specific installer ($_DETECTED_PLATFORM)"
		;;
	*)
		_error "Unsupported platform"
		;;
	esac
	_APPLICATION_START_TIME=$(date +%s)
	_APPLICATION_CMD=$(basename $0)
	unset _DEFERS
	for _ARG in "$@"; do
		case $_ARG in
		-h | --help)
			_print_help_and_exit
			;;
		-kill-all)
			_kill_all
			_success "Killed all"
			;;
		-kill-all-group)
			_kill_all_group
			_success "Killed all group"
			;;
		-kill=*)
			_kill ${_ARG#*=}
			_success "Killed ${_ARG#*=}"
			;;
		-l)
			_list
			_success "listed running processes"
			;;
		-lg)
			_list_group
			_success "listed running processes"
			;;
		-w=*)
			_WAITER_PID="${1#*=}"
			shift
			;;
		-w)
			_CONF_INSTALL_WAITER_LEVEL=_info
			_WAITEE=1
			shift
			;;
		-conf-* | -[a-z0-9][a-z0-9][a-z0-9]*)
			_configuration_name=${_ARG#*-}
			_configuration_name=${_configuration_name%%=*}
			if [ $(printf '%s' "$_configuration_name" | grep -c '_') -eq 0 ]; then
				if [ $(printf '%s' "$_configuration_name" | grep -c '^conf') -gt 0 ]; then
					_configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/-/-$_APPLICATION_NAME-/")
				else
					_configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/^/$_APPLICATION_NAME-/")
				fi
			fi
			_configuration_name=$(printf '%s' $_configuration_name | tr '-' '_' | tr '[:lower:]' '[:upper:]')
			if [ $(printf '%s' "$_ARG" | grep -c '=') -eq 0 ]; then
				_configuration_value=1
			else
				_configuration_value=${_ARG#*=}
			fi
			export _$_configuration_name="$_configuration_value"
			unset _configuration_name
			shift
			;;
		*)
			break
			;;
		esac
	done
	trap _on_exit INT 0 1 2 3 4 6 15
	_init_logging
	_init_application_context
	_debug "REMAINING ARGS: $*"
	_log_app_init
	_init_pager
	_waiter
	_has_required_conf
	if [ -n "$_REQUIRED_ARGUMENTS" ]; then
		_DISCOVERED_ARGUMENT_COUNT=$(printf '%s' "$_REQUIRED_ARGUMENTS" | sed -e 's/$/\n/' | tr '|' '\n' | wc -l | awk {'print$1'})
		_required_arguments_argument_log_level=debug
		_ACTUAL_ARGUMENT_COUNT=$#
		[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _required_arguments_argument_log_level=warn
		_$_required_arguments_argument_log_level "Expecting $_DISCOVERED_ARGUMENT_COUNT, received $# arguments"
		_INDEX=1
		_ARGUMENT_LOG_LEVEL=info
		while [ $_INDEX -le $_DISCOVERED_ARGUMENT_COUNT ]; do
			_ARGUMENT_NAME=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_INDEX}p | sed -e 's/:.*$//')
			_ARGUMENT_MESSAGE=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_INDEX}p | sed -e 's/^.*://')
			if [ -z "$1" ]; then
				_$_required_arguments_argument_log_level "$_INDEX:$_ARGUMENT_MESSAGE was not provided"
			else
				_$_required_arguments_argument_log_level "$_INDEX:$_ARGUMENT_NAME=$1"
				export $_ARGUMENT_NAME="$1"
				shift
			fi
			_INDEX=$(($_INDEX + 1))
		done
		[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _error "Missing arguments"
		unset _INDEX _ARGUMENT_NAME _ARGUMENT_MESSAGE _required_arguments_argument_log_level
		_DISCOVERED_REQUIRED_ARGUMENTS="$_REQUIRED_ARGUMENTS"
		unset _REQUIRED_ARGUMENTS
	else
		_debug "NO _REQUIRED_ARGUMENTS args"
		unset _DISCOVERED_REQUIRED_ARGUMENTS _DISCOVERED_ARGUMENT_COUNT
	fi
	$_CONF_INSTALL_GNU_SED -i 's/public //' $_JAVA_INTERFACE
	_JAVA_INTERFACE_NAME=$(basename $_JAVA_INTERFACE | sed -e "s/\.java$//")
	if [ $(grep -c "^public interface $_JAVA_INTERFACE_NAME" $_JAVA_INTERFACE) -eq 0 ]; then
		$_CONF_INSTALL_GNU_SED -i "s/interface $_JAVA_INTERFACE_NAME/public interface $_JAVA_INTERFACE_NAME/" $_JAVA_INTERFACE
	fi
done
