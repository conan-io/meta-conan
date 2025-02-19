SUMMARY = "Library to parse and apply unified diffs"
HOMEPAGE = "https://github.com/conan-io/python-patch-ng"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;beginline=67;endline=67;md5=e0cee1d4846adf8bd48d77481828c537"

SRC_URI[md5sum] = "9577002808a51557e29e52730f8bbda4"
SRC_URI[sha256sum] = "52fd46ee46f6c8667692682c1fd7134edc65a2d2d084ebec1d295a6087fc0291"

inherit setuptools3 python3-dir pypi

# This is packaged poorly
#PYPI_PACKAGE_EXT = "zip"
#S = "${WORKDIR}"

BBCLASSEXTEND = "native nativesdk"
