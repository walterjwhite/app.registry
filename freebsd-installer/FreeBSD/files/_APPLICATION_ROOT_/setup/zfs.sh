_zfs_jail=0
_zfs_restore() {
	_info "_zfs_restore: $1"
	mkdir -p ~/.ssh/socket
	chmod 700 ~/.ssh/socket
	. $1
	[ -z "$_ZFS_DEV_NAME" ] && {
		_warn "_ZFS_DEV_NAME is empty"
		return 1
	}
	[ -z "$_ZFS_SOURCE_HOST" ] && {
		_warn "_ZFS_SOURCE_HOST is empty"
		return 1
	}
	[ -z "$_ZFS_VOLUME_NAME" ] && {
		_warn "_ZFS_VOLUME_NAME is empty"
		return 1
	}
	_ZFS_VOLUME=${_ZFS_DEV_NAME}/$_ZFS_VOLUME_NAME
	_ZFS_SOURCE_SNAPSHOT=$(ssh $_ZFS_SOURCE_HOST zfs list -H -t snapshot | grep $_ZFS_VOLUME_NAME@ | grep -v backups | tail -1 | awk {'print$1'})
	[ -z "$_ZFS_SOURCE_SNAPSHOT" ] && {
		_warn "No snapshots available, unable to setup clone: $_ZFS_VOLUME"
		return 1
	}
	_zfs_has_sufficient_space || return 1
	_info "zfs create $_ZFS_VOLUME"
	zfs create -p $_ZFS_VOLUME
	[ -n "$_ZFS_MOUNT_POINT" ] && zfs set mountpoint=$_ZFS_MOUNT_POINT $_ZFS_VOLUME
	zfs set readonly=on $_ZFS_VOLUME
	ssh $_ZFS_SOURCE_HOST zfs send -v $_ZFS_SOURCE_SNAPSHOT | zfs receive -F $_ZFS_VOLUME
	zfs allow -g wheel bookmark,diff,hold,send,snapshot $_ZFS_VOLUME
	if [ -n "$_CONF_SYSTEM_MAINTENANCE_ZFS_USER" ]; then
		zfs allow -u $_CONF_SYSTEM_MAINTENANCE_ZFS_USER bookmark,diff,hold,send,snapshot $_ZFS_VOLUME
	fi
	if [ -n "$_ZFS_ZAP_SNAP" ]; then
		_warn "Detected ZFS ZAP, setting up zap"
		zfs set zap:snap=on $_ZFS_VOLUME
		zfs allow -u zap bookmark,diff,hold,send,snapshot $_ZFS_VOLUME
	fi
	if [ -n "$_ZFS_ZAP_TTL" ]; then
		zfs set zap:ttl=$_ZFS_ZAP_TTL $_ZFS_VOLUME
	fi
	if [ -n "$_ZFS_ZAP_BACKUP" ]; then
		zfs set zap:backup=$_ZFS_ZAP_BACKUP $_ZFS_VOLUME
	fi
	if [ -n "$_ZFS_RCLONE_TARGET" ]; then
		zfs set rclone:target=$_ZFS_RCLONE_TARGET $_ZFS_VOLUME
	fi
	if [ -n "$_ZFS_RCLONE_PATH" ]; then
		zfs set rclone:path=$_ZFS_RCLONE_PATH $_ZFS_VOLUME
	fi
	_info "zfs create $_ZFS_VOLUME - done"
}
_zfs_has_sufficient_space() {
	_ZFS_SNAPSHOT_SPACE=$(ssh $_ZFS_SOURCE_HOST zfs list -t snapshot $_ZFS_SOURCE_SNAPSHOT | awk '{print$4}' | grep "G$" | sed -e "s/G$//")
	_ZFS_SNAPSHOT_REQUIRED_SPACE=$(printf '2 * %s\n' "$_ZFS_SNAPSHOT_SPACE" | bc)
	_ZPOOL_FREE_SPACE=$(zpool list -H $_ZFS_DEV_NAME | awk '{print$4}' | grep "G$" | sed -e "s/G$//")
	if [ $(printf '%s < %s\n' "$_ZFS_SNAPSHOT_REQUIRED_SPACE" "$_ZPOOL_FREE_SPACE" | bc) -eq 0 ]; then
		_warn "Insufficient free space: $_ZFS_VOLUME_NAME - $_ZFS_SNAPSHOT_SPACE $_ZFS_SNAPSHOT_REQUIRED_SPACE $_ZPOOL_FREE_SPACE"
		return 1
	fi
	_info "Setting up $_ZFS_VOLUME_NAME - $_ZFS_SNAPSHOT_SPACE $_ZFS_SNAPSHOT_REQUIRED_SPACE $_ZPOOL_FREE_SPACE"
}
_zfs() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/zfs\""
	fi
	local zfs_volume_configuration
	for zfs_volume_configuration in $(find patches -type f -path '*/*.patch/zfs/*' $variant_options | sort); do
		_zfs_restore $zfs_volume_configuration
		unset _ZFS_DEV_NAME _ZFS_SOURCE_HOST _ZFS_VOLUME_NAME _ZFS_VOLUME_ABORT_CREATE _ZFS_ZAP_SNAP _ZFS_ZAP_TTL _ZFS_ZAP_BACKUP _ZFS_MOUNT_POINT _ZFS_VOLUME
	done
}
