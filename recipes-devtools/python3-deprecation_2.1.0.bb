DESCRIPTION = "A library to handle automated deprecations"
HOMEPAGE = "http://deprecation.readthedocs.io/en/latest/"
SECTION = "devel/python"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI[md5sum] = "6b79c6572fb241e3cecbbd7d539bb66b"
SRC_URI[sha256sum] = "72b3bde64e5d778694b0cf68178aed03d15e15477116add3fb773e581f9518ff"

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-packaging \
"

DEPENDS_class-native = "\
    ${PYTHON_PN}-packaging-native \
"

inherit setuptools3 python3-dir pypi

BBCLASSEXTEND = "native nativesdk"
