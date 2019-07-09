SUMMARY = "Fast, Extensible Progress Meter"
HOMEPAGE = "https://github.com/tqdm/tqdm"
AUTHOR = "tqdm developers <python.tqdm@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENCE;md5=054ef7105cba050017d1368262a1623c"

SRC_URI[md5sum] = "807e8c13e16e3660ac88e05d711daeb0"
SRC_URI[sha256sum] = "e22977e3ebe961f72362f6ddfb9197cc531c9737aaf5f607ef09740c849ecd05"

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-multiprocessing \
    ${PYTHON_PN}-threading \
"

inherit pypi

BBCLASSEXTEND = "native nativesdk"
