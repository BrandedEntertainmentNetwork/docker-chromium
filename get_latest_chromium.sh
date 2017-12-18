#!/bin/bash
#
# Get a chromium build to /opt.
#
# This script is inspired by:
# > https://github.com/scheib/chromium-latest-linux/blob/master/update.sh
# but I removed all the steps not needed for a docker headless build.
set -e

LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"

if [ -z ${CHROMIUM_REVISION} ]; then
  CHROMIUM_REVISION="latest"
fi

if [ "${CHROMIUM_REVISION}" == "latest" ]; then
  REVISION=$( curl -s -S ${LASTCHANGE_URL} )
else
  REVISION="${CHROMIUM_REVISION}"
fi

ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${REVISION}%2Fchrome-linux.zip?alt=media"

echo "Obtained revision ${REVISION}"

cd /tmp
echo "Downloading zip file"
wget -q ${ZIP_URL} -O chrome-linux.zip

echo "Unpacking into /opt/chrome-linux"
unzip chrome-linux.zip
mv chrome-linux /opt/chrome-linux

echo "Revision used for build: ${REVISION}
Details: http://crrev.com/${REVISION}
Build date: $( date )
" > /opt/chromium_version.txt

cat /opt/chromium_version.txt
