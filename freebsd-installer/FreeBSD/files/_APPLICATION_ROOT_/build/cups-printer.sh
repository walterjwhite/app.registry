_cups_printer_add() {
	_cups_printer_exists $1 || {
		_info "Adding $1"
		cat $1 >>/usr/local/etc/cups/printers.conf
	}
}
_cups_printer_exists() {
	if [ ! -e /usr/local/etc/cups/printers.conf ]; then
		return 1
	fi
	local printer_uuid=$(grep ^UUID $1 | sed -e 's/UUID urn:uuid://')
	if [ $(grep -c $printer_uuid /usr/local/etc/cups/printers.conf) -eq 0 ]; then
		return 1
	fi
	_warn "Printer ($printer_uuid) already exists"
	return 0
}
_cups_printer() {
	local variant_options=""
	if [ -n "$_VARIANT" ]; then
		variant_options="-or -path \"*/*.patch/variants/$_VARIANT/cups-printer/*\""
	fi
	local _CUPS_PRINTER_FILE
	for _CUPS_PRINTER_FILE in $(find patches -type f -path '*/*.patch/cups-printer/*' $variant_options | sort); do
		_cups_printer_add $_CUPS_PRINTER_FILE
	done
}
