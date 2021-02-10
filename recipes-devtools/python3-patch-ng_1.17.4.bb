SUMMARY = "Library to parse and apply unified diffs"
HOMEPAGE = "https://github.com/conan-io/python-patch-ng"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;beginline=67;endline=67;md5=0754c663425c81a845272675d7f7dbdb"

SRC_URI[md5sum] = "6e9371b9e6531ccdfb43e7ad883b3ff5"
SRC_URI[sha256sum] = "627abc5bd723c8b481e96849b9734b10065426224d4d22cd44137004ac0d4ace"

inherit setuptools3 python3-dir pypi

# This is packaged poorly
#PYPI_PACKAGE_EXT = "zip"
#S = "${WORKDIR}"

BBCLASSEXTEND = "native nativesdk"
