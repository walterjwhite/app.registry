_freebsd_update_jail=0
_freebsd_update() {
	env PAGER=cat freebsd-update --not-running-from-cron fetch install
}
