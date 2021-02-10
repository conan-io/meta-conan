SUMMARY = "A python package that provides useful locks."
HOMEPAGE = "https://github.com/harlowja/fasteners"
AUTHOR = "Joshua Harlow <harlowja@yahoo-inc.com>"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4476c4be31402271e101d9a4a3430d52"

SRC_URI[md5sum] = "fcb13261c9b0039d9b1c4feb9bc75e04"
SRC_URI[sha256sum] = "427c76773fe036ddfa41e57d89086ea03111bbac57c55fc55f3006d027107e18"

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-six \
    ${PYTHON_PN}-monotonic \
    ${PYTHON_PN}-fcntl \
"

DEPENDS_class-native = "\
    ${PYTHON_PN}-six-native \
    ${PYTHON_PN}-monotonic-native \
"

inherit pypi

BBCLASSEXTEND = "native nativesdk"
