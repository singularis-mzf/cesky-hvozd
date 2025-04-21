#!/bin/sh

# get version argument
VERS="$1"
if [ ! "$VERS" ];then
   echo "Argument version expected: example ./make_release.sh 2.5.0"
   exit 1
fi

# cd to root dir
cd "$(dirname "$0")"
AROOT="$(pwd)"
echo "Working directory is: $AROOT"
# create temp directory
TMP=$(mktemp -d -t advtrains-XXXX)
echo "Temp directory is: $TMP"
mkdir "$TMP/advtrains"
TDIR="$TMP/advtrains/"

# copy dirs
cp -r "advtrains" "$TDIR"
cp -r "advtrains_interlocking" "$TDIR"
cp -r "advtrains_line_automation" "$TDIR"
cp -r "advtrains_luaautomation" "$TDIR"
cp -r "advtrains_signals_ks" "$TDIR"
cp -r "advtrains_signals_japan" "$TDIR"
cp -r "advtrains_signals_muc_ubahn" "$TDIR"
cp -r "advtrains_train_track" "$TDIR"
cp -r "serialize_lib" "$TDIR"

# copy files
cp "atc_command.txt" "$TDIR"
cp "description.txt" "$TDIR"
cp "license.txt" "$TDIR"
cp "license_media.txt" "$TDIR"
cp "modpack.conf" "$TDIR"
cp "privilege_guide.txt" "$TDIR"
cp "README.md" "$TDIR"
cp "screenshot.png" "$TDIR"

# compress to zip archive
ZIPNAME="$AROOT/advtrains_$VERS.zip"
echo "Target ZIP file is: $ZIPNAME"
cd "$TMP"
zip -r "$ZIPNAME" "advtrains"
cd "$AROOT"

# success
echo "Release $VERS created at: $ZIPNAME"

# remove tempdir
rm -rf "$TMP"

