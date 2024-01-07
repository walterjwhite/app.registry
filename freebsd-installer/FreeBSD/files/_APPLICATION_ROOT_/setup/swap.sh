_swap() {
	local swap_device=$(grep swap /etc/fstab 2>/dev/null | awk {'print$1'})
	if [ -n "$swap_device" ]; then
		swapon $swap_device
	fi
}
