DESCRIPTION = "A library to handle automated deprecations"
HOMEPAGE = "http://deprecation.readthedocs.io/en/latest/"
SECTION = "devel/python"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI[md5sum] = "7fc1b0592c47d90306dfdcb6ea46d8c8"
SRC_URI[sha256sum] = "68071e5ae7cd7e9da6c7dffd750922be4825c7c3a6780d29314076009cc39c35"

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-packaging \
"

DEPENDS_class-native = "\
    ${PYTHON_PN}-packaging-native \
"

inherit pypi

BBCLASSEXTEND = "native nativesdk"
