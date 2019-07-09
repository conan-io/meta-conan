# The python3 version is not packaged because it is part of python3.
# Fasteners unfortunatly requires it still, really should drop this
# and patch that package.

SUMMARY = "An implementation of time.monotonic() for Python 2.0 through 3.2"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d2794c0df5b907fdace235a619d80314"

SRC_URI[md5sum] = "9f81cb0e5966479754453dea2b6822f4"
SRC_URI[sha256sum] = "23953d55076df038541e648a53676fb24980f7a1be290cdda21300b3bc21dfb0"

inherit pypi setuptools3

RDEPENDS_${PN} += "${PYTHON_PN}-ctypes ${PYTHON_PN}-io ${PYTHON_PN}-threading"

BBCLASSEXTEND += "native nativesdk"
