#!/sbin/sh
#
# Thanks show-p1984 for this script
if [ -e /system/bin/mpdecision_bck ] ; then
	busybox mv /system/bin/mpdecision_bck /system/bin/mpdecision
fi
if [ -e /system/bin/thermald_bck ] ; then
	busybox mv /system/bin/thermald_bck /system/bin/thermald
fi
return $?
