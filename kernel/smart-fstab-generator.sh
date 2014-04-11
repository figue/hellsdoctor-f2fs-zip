#!/sbin/sh
#
# This script wants to be a simple solution to generate a fstab for Mako
# 
# Script parse its own name and write every partition entry into f2fs filesystem.
#
# Creator: ffigue <arroba> gmail.com
#
#    License:
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Sources:
# https://android.googlesource.com/device/lge/mako/+/master/fstab.mako
# http://forum.xda-developers.com/showpost.php?p=51659075

basename=$(ps wwwwwwwwwwwww | grep -v grep | grep -o -E "/tmp/updater(.*)")
echo "Parsing basename for fstab.mako: $basename"
fstabfile="/tmp/fstab.mako"

# Start fstab generator
cat << EOF > $fstabfile
# Android fstab file.
#<src>                                         <mnt_point>  <type>  <mnt_flags and options>  <fs_mgr_flags>
# The filesystem that contains the filesystem checker binary (typically /system) cannot
# specify MF_CHECK, and must come before any filesystems that do specify MF_CHECK

EOF

# Writting /system
if echo $basename | grep -q system ; then
	echo "/dev/block/platform/msm_sdcc.1/by-name/system       /system         f2fs    ro,noatime,nosuid,nodev,discard,nodiratime,inline_xattr,errors=recover    wait" >> $fstabfile
else
	echo "/dev/block/platform/msm_sdcc.1/by-name/system       /system         ext4    ro,barrier=1                                                    wait" >> $fstabfile
fi

# Writting /cache
if echo $basename | grep -q cache ; then                                                                                                                                              
    echo "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    noatime,nosuid,nodev,discard,nodiratime,inline_xattr,errors=recover       wait,check" >> $fstabfile
else
	echo "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          ext4    noatime,nosuid,nodev,barrier=1,data=ordered                     wait,check" >> $fstabfile
fi

# Writting /data
if echo $basename | grep -q data ; then
	echo "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    noatime,nosuid,nodev,discard,nodiratime,inline_xattr,errors=recover       wait,check,encryptable=/dev/block/platform/msm_sdcc.1/by-name/metadata" >> $fstabfile
else
	echo "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           ext4    noatime,nosuid,nodev,barrier=1,data=ordered,noauto_da_alloc     wait,check,encryptable=/dev/block/platform/msm_sdcc.1/by-name/metadata" >> $fstabfile
fi

cat << EOF >> $fstabfile
/dev/block/platform/msm_sdcc.1/by-name/persist      /persist        ext4    nosuid,nodev,barrier=1,data=ordered,nodelalloc                  wait
/dev/block/platform/msm_sdcc.1/by-name/modem        /firmware       vfat    ro,uid=1000,gid=1000,dmask=227,fmask=337                        wait
/dev/block/platform/msm_sdcc.1/by-name/boot         /boot           emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/recovery     /recovery       emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/misc         /misc           emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/modem        /radio          emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/sbl1         /sbl1           emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/sbl2         /sbl2           emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/sbl3         /sbl3           emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/tz           /tz             emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/rpm          /rpm            emmc    defaults                                                        defaults
/dev/block/platform/msm_sdcc.1/by-name/aboot        /aboot          emmc    defaults                                                        defaults

EOF

