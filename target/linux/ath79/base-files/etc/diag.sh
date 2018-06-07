#!/bin/sh

. /lib/functions/leds.sh

status_led="$(get_dt_led status)"

get_status_led() {
	local board=$(board_name)
	local boardname="${board##*,}"

	case $board in
	"avm,fritz300e")
		status_led="${boardname}:green:power"
		;;
	"embeddedwireless,dorin")
		status_led="dorin:green:status"
		;;
	"glinet,ar150")
		status_led="gl-ar150:orange:wlan"
		;;
	"tplink,tl-wr1043nd-v1")
		status_led="tp-link:green:system"
		;;
	"ubnt,unifi")
		status_led="ubnt:green:dome"
		;;
	esac
}

set_state() {
	[ -z "$status_led" ] && get_status_led

	case "$1" in
	preinit)
		status_led_blink_preinit
		;;
	failsafe)
		status_led_blink_failsafe
		;;
	preinit_regular)
		status_led_blink_preinit_regular
		;;
	done)
		status_led_on
		;;
	esac
}
