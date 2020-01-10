#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
PROJECT_DIR=$(readlink -f $SCRIPTPATH/../)

set -e

PATH=/usr/bin:$PATH
export PATH="${PATH}"

/bin/echo "${PROJECT_DIR}"

cd ${PROJECT_DIR}

STAGE_DIR=/tmp/linuxdeployqt
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
DIST_DIR=${PROJECT_DIR}/dist
BUILD_DIR=${STAGE_DIR}/build
BASE_DIR=${STAGE_DIR}/usr
ARCH="$(/usr/bin/dpkg --print-architecture)"
set -e

/bin/echo "Starting ..."
/bin/echo "Arch: ${ARCH}"
/bin/echo "Directory (dist): ${DIST_DIR}"
/bin/echo "Directory (base): ${BASE_DIR}"
/bin/echo "Directory (build): ${BUILD_DIR}"
/bin/echo "Directory (stage): ${STAGE_DIR}"

/bin/echo "Cleaning ..."
/usr/bin/sudo /bin/rm -rf ${STAGE_DIR}
/bin/echo "OK!"

/bin/echo "Creating package structure and files ..."
/bin/mkdir -p ${DIST_DIR}
/bin/mkdir -p ${BUILD_DIR}
/bin/mkdir -p ${BASE_DIR}
/bin/mkdir -p ${STAGE_DIR}/DEBIAN
/bin/mkdir -p ${STAGE_DIR}/usr/local/bin
/usr/bin/sudo /bin/cp -rf ${PROJECT_DIR}/linuxdeployqt ${STAGE_DIR}/usr/local/bin/

/bin/cat >> ${STAGE_DIR}/DEBIAN/control <<EOF
Package: linuxdeployqt
Priority: extra
Section: devel
Maintainer: I9CORP <repo@i9corp.com.br>
Version: @VERSION@
Depends: fuse
Description: Pacote da I9Corp para instalação do utilitário linuxdeployqt.
EOF
echo "Architecture: ${ARCH}" >> ${STAGE_DIR}/DEBIAN/control

/bin/cat >> ${STAGE_DIR}/DEBIAN/postinst <<EOF
#!/bin/bash
set -e
chmod +x /usr/local/bin/linuxdeployqt
exit 0
EOF

/bin/cat >> ${STAGE_DIR}/DEBIAN/prerm <<EOF
#!/bin/bash
set -e
if [ -f /usr/local/bin/linuxdeployqt ]; then
    rm -fr /usr/local/bin/linuxdeployqt
fi
exit 0
EOF
echo "Ok!"

/bin/echo "Copying files and changing permissions ..."
/usr/bin/sudo /bin/cp -rf ${PROJECT_DIR}/dist/* ${BASE_DIR}/
/bin/chmod 755 ${STAGE_DIR}/DEBIAN/control
/bin/echo "Ok!"

echo "Creating package..."
/usr/bin/dpkg -b ${STAGE_DIR} ${DIST_DIR}/linuxdeployqt_@VERSION@_${ARCH}.deb
/bin/echo "Ok!"

echo "Done!";

