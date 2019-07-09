SUMMARY = "Core utilities for Python packages "
DESCRIPTION = "Core utilities for Python packages "
HOMEPAGE = "https://github.com/pypa/packaging"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=faadaedca9251a90b205c9167578ce91"

SRC_URI[md5sum] = "dd118dc389f8e90840d44240292bf3d9"
SRC_URI[sha256sum] = "0c98a5d0be38ed775798ece1b9727178c4469d9c3b4ada66e8e6b7849f8732af"

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-six \
    ${PYTHON_PN}-pyparsing \
"

DEPENDS_class-native = "\
    ${PYTHON_PN}-six-native \
    ${PYTHON_PN}-pyparsing-native \
"

inherit pypi

BBCLASSEXTEND = "native nativesdk"
