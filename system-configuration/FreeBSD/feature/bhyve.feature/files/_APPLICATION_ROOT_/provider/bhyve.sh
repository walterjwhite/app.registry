_bhyve_create() {
	_OPTIONS=""
	if [ -n "$_SIZE" ]; then
		_OPTIONS="$_OPTIONS -s $_SIZE"
	fi
	if [ -n "$_MEMORY" ]; then
		_OPTIONS="$_OPTIONS -m $_MEMORY"
	fi
	if [ -n "$_CPUS" ]; then
		_OPTIONS="$_OPTIONS -c $_CPUS"
	fi
	if [ -n "$_TEMPLATE" ]; then
		_OPTIONS="$_OPTIONS -t $_TEMPLATE"
	fi
	vm create $_VM_NAME $_OPTIONS
}
_bhyve_copy_conf() {
	cp -R $BHYVE_VM_TEMPLATES/$_VM_NAME/* /$BHYVE_VM_DIR/$_VM_NAME/
	mv /$BHYVE_VM_DIR/$_VM_NAME/vm-bhyve.conf /$BHYVE_VM_DIR/$_VM_NAME/$_VM_NAME.conf
}
_bhyve_image() {
	if [ -n "$_ISO_FILENAME" ]; then
		if [ ! -e "/$BHYVE_VM_DIR/.iso/$_ISO_FILENAME" ]; then
			vm iso $_ISO_URL
		fi
		return
	fi
	_bhyve_cloud_image
}
_bhyve_cloud_image() {
	:
}
_bhyve_install() {
	export _VM_NAME _ISO_FILENAME _HOSTNAME _VERSION _IP_ADDRESS
	local _original_wd=$PWD
	cd /$BHYVE_VM_DIR/$_VM_NAME
	_info "Installing VM: $_VM_NAME"
	timeout -k $_BHYVE_KILL_BHYVE_TIMEOUT $_BHYVE_TIMEOUT /$BHYVE_VM_DIR/$_VM_NAME/install
	cd $_original_wd
	zap snap 30d $BHYVE_VM_DIR/$_VM_NAME
	unset _ISO_FILENAME _ISO_URL
}
_bhyve_provision() {
	for _VM in $(find $BHYVE_VM_TEMPLATES -maxdepth 1 -type d ! -name 'vms'); do
		_VM_NAME=$(basename $_VM)
		_info "Preparing VM: $_VM_NAME"
		if [ $(vm list | sed 1d | awk {'print$1'} | grep -c $_VM_NAME) -gt 0 ]; then
			_warn "$_VM_NAME is already installed, aborting"
			continue
		fi
		_info "Reading conf for VM: $_VM_NAME"
		. $BHYVE_VM_TEMPLATES/$_VM_NAME/configuration
		_bhyve_create
		_bhyve_copy_conf
		_bhyve_image
		_bhyve_install
	done
}
_bhyve_init() {
	BHYVE_VM_TEMPLATES=/usr/local/etc/walterjwhite/vms
	if [ ! -e $BHYVE_VM_TEMPLATES ]; then
		_warn "$BHYVE_VM_TEMPLATES does not exist, aborting"
		return 1
	fi
	if [ ! -e ~/.ssh/authorized_keys ]; then
		_warn "~/.ssh/authorized_keys does *NOT* exist, it is required to SSH into guests"
		return 1
	fi
	DEV_NAME=$(zfs list | grep ROOT | awk {'print$1'} | grep ROOT$ |
		sed -e "s/\/ROOT//" |
		head -1)
	BHYVE_VM_DIR=$DEV_NAME/vms
	_BHYVE_KILL_BHYVE_TIMEOUT=1m
	_BHYVE_TIMEOUT=5m
	vm init
	vm switch create public 2>/dev/null
	vm switch add public wired 2>/dev/null
	_SSH_PUBLIC_KEY=$(cat ~/.ssh/authorized_keys)
}
_bhyve() {
	_bhyve_init && _bhyve_provision
}
