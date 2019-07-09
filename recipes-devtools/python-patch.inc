SUMMARY = "Library to parse and apply unified diffs"
HOMEPAGE = "https://github.com/techtonik/python-patch/"
AUTHOR = "anatoly techtonik <techtonik@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;beginline=10;endline=10;md5=0754c663425c81a845272675d7f7dbdb"

SRC_URI[md5sum] = "dbcbbd4e45ddd8baeb02bddf663a3176"
SRC_URI[sha256sum] = "c62073f356cff054c8ac24496f1a3d7cfa137835c31e9af39a9f5292fd75bd9f"


inherit pypi

# This is packaged poorly
PYPI_PACKAGE_EXT = "zip"
S = "${WORKDIR}"

BBCLASSEXTEND = "native nativesdk"
