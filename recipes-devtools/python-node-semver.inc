SUMMARY = "port of node-semver"
HOMEPAGE = "https://github.com/podhmo/python-semver"
AUTHOR = "podhmo <ababjam61+github@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;beginline=62;endline=62;md5=1afbb36cec1f919e9b0fe08f27771c02"

SRC_URI[md5sum] = "e7f200b9d2605f2e57543dcc19d58d32"
SRC_URI[sha256sum] = "4016f7c1071b0493f18db69ea02d3763e98a633606d7c7beca811e53b5ac66b7"

RDEPENDS_${PN} = ""

inherit pypi

BBCLASSEXTEND = "native nativesdk"
