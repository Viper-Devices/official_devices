#!/bin/bash
myname="$0"
function help() {
    cat <<EOF
Syntax:
  $myname <device> <folder_of_rom>
for example:
$myname cedric viper
EOF
}


if [ -z "$2" ];then
	>&2 help
else

device=$1
sourcerom=$2
DATE="$(date +%Y%m%d)"
DAY="$(date +%d/%m/%Y)"
zip_path=~/$sourcerom/out/target/product/$device/*$DATE*.zip
set -e

if [ ! -d ~/official_devices ];then
cd ~
git clone https://github.com/Viper-devices/official_devices.git -b pie
fi

if [ -d ~/official_devices ];then
# datetime
timestamp=`cat ~/$sourcerom/out/target/product/$device/system/build.prop | grep ro.build.date.utc | cut -d'=' -f2`
timestamp_old=`cat ~/official_devices/$device/$device.json | grep "datetime" | cut -d':' -f2 | cut -d'"' -f2`
`sed -i "s|$timestamp_old|$timestamp|g" ~/official_devices/$device/$device.json`

# filename
zip_name=`echo $zip_path | cut -d'/' -f9`
zip_name_old=`cat ~/official_devices/$device/$device.json | grep "filename" | cut -d':' -f2 | cut -d'"' -f2`
`sed -i "s|$zip_name_old|$zip_name|g" ~/official_devices/$device/$device.json`

# id
id=`md5sum $zip_path | cut -d' ' -f1`
id_old=`cat ~/official_devices/$device/$device.json | grep "id" | cut -d':' -f2 | cut -d'"' -f2`
`sed -i "s|$id_old|$id|g" ~/official_devices/$device/$device.json`

# Rom size
size_new=`stat -c "%s" $zip_path`
size_old=`cat ~/official_devices/$device/$device.json | grep "size" | cut -d':' -f2 | cut -d',' -f1`
`sed -i "s|$size_old|$size_new|g" ~/official_devices/$device/$device.json`

# url
url="https://master.dl.sourceforge.net/project/viper-project/$device/$zip_name"
url_old=`cat ~/official_devices/$device/$device.json | grep https | cut -d '"' -f4`
`sed -i "s|$url_old|$url|g" ~/official_devices/$device/$device.json`

# copy changelog
changelog=`cp ~/$sourcerom/out/target/product/$device/system/etc/Changelog.txt ~/official_devices/$device/changelog.txt`

# add & push commit to github
cd official_devices
git add --all
git commit -m "$device: update $DAY"
git push -f origin HEAD:pie
cd ~
rm -rf official_devices
rm -rf Jsoncreate.sh
fi

fi
