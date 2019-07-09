SUMMARY = "Pygments is a syntax highlighting package written in Python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://PKG-INFO;beginline=8;endline=8;md5=88df8e78b9edfd744953862179f2d14e"

SRC_URI[md5sum] = "13037baca42f16917cbd5ad2fab50844"
SRC_URI[sha256sum] = "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"

PYPI_PACKAGE = "Pygments"

inherit pypi

BBCLASSEXTEND = "native nativesdk"
