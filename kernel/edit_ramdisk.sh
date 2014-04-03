#!/sbin/sh
#THANKS to showp for the great script
#Features:
#extracts ramdisk
#remove thermald & mpdecision
#finds busybox in /system or sets default location if it cannot be found
#Check sysinit & runparts add init.d support if not already supported
#repacks the ramdisk

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
sed -i '/mpdecision/{n; /class main$/d}' init.mako.rc
sed -i '/thermald/{n; /class main$/d}' init.mako.rc
sed -i '/mpdecision/d' init.mako.rc
sed -i '/thermald/d' init.mako.rc
cd /

PACK()
{
# REPACK RAMDISK
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cd /tmp/ramdisk/
cp -v /tmp/fstab.mako .
find . | cpio -o -H newc | gzip > ../boot.img-ramdisk.gz
cd /
}

ADD()
{
#add init.d support if not already supported
found=$(find /tmp/ramdisk/init.rc -type f | xargs grep -oh "run-parts /system/etc/init.d");
if [ "$found" != 'run-parts /system/etc/init.d' ]; then
        #find busybox in /system
        bblocation=$(find /system/ -name 'busybox')
        if [ -n "$bblocation" ] && [ -e "$bblocation" ] ; then
                echo "BUSYBOX FOUND!";
                #strip possible leading '.'
                bblocation=${bblocation#.};
        else
                echo "NO BUSYBOX NOT FOUND! init.d support will not work without busybox!";
                echo "Setting busybox location to /system/xbin/busybox! (install it and init.d will work)";
                #set default location since we couldn't find busybox
                bblocation="/system/xbin/busybox";
        fi
	#append the new lines for this option at the bottom
        echo "" >> /tmp/ramdisk/init.rc
        echo "service userinit $bblocation run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
        echo "    oneshot" >> /tmp/ramdisk/init.rc
        echo "    class late_start" >> /tmp/ramdisk/init.rc
        echo "    user root" >> /tmp/ramdisk/init.rc
        echo "    group root" >> /tmp/ramdisk/init.rc
fi
PACK
}
# Prüfe existierendes sysinit/run-parts
SYSINIT=`grep -irq sysinit /tmp/ramdisk/*.rc;echo $?`
RUNPARTS=`grep -irq run-parts /tmp/ramdisk/*.rc;echo $?`
case $SYSINIT in
	1) 		if [ "$RUNPARTS" != "0" ]
				then ADD
					else PACK
			fi ;;
	*) PACK;;
esac

