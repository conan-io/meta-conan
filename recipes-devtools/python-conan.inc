SUMMARY = "Conan C/C++ package manager"
HOMEPAGE = "https://conan.io"
AUTHOR = "JFrog LTD <luism@jfrog.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=1e486b3d16485847635c786d2b7bd32a"

SRC_URI[md5sum] = "c316e5021cc29d926f9bcca0f3f9754d"
SRC_URI[sha256sum] = "41ca5d8b70f8d77c058c7a1cba7dec5dc8e321f5c139214ab30f58bb89b77993"

inherit pypi update-alternatives

# Overwrite the script to disable run-time dependency checking
do_install_append(){
    rm ${D}${bindir}/conan
    cat >> ${D}${bindir}/conan <<EOF
#!/usr/bin/env ${PYTHON_PN}
from conans.conan import run
run()
EOF
    chmod 755 ${D}${bindir}/conan
}

# Version in meta-python too old:
#   ${PYTHON_PN}-pylint
#   ${PYTHON_PN}-deprecation

RDEPENDS_${PN} = "\
    ${PYTHON_PN}-pyjwt \
    ${PYTHON_PN}-requests \
    ${PYTHON_PN}-colorama \
    ${PYTHON_PN}-pyyaml \
    ${PYTHON_PN}-patch \
    ${PYTHON_PN}-fasteners \
    ${PYTHON_PN}-six \
    ${PYTHON_PN}-node-semver \
    ${PYTHON_PN}-distro \
    ${PYTHON_PN}-pylint \
    ${PYTHON_PN}-future \
    ${PYTHON_PN}-pygments \
    ${PYTHON_PN}-astroid \
    ${PYTHON_PN}-deprecation \
    ${PYTHON_PN}-tqdm \
    ${PYTHON_PN}-jinja2 \
    ${PYTHON_PN}-sqlite3 \
"

DEPENDS_class-native = "\
    ${PYTHON_PN}-pyjwt-native \
    ${PYTHON_PN}-requests-native \
    ${PYTHON_PN}-colorama-native \
    ${PYTHON_PN}-pyyaml-native \
    ${PYTHON_PN}-patch-native \
    ${PYTHON_PN}-fasteners-native \
    ${PYTHON_PN}-six-native \
    ${PYTHON_PN}-node-semver-native \
    ${PYTHON_PN}-distro-native \
    ${PYTHON_PN}-pylint-native \
    ${PYTHON_PN}-future-native \
    ${PYTHON_PN}-pygments-native \
    ${PYTHON_PN}-astroid-native \
    ${PYTHON_PN}-deprecation-native \
    ${PYTHON_PN}-tqdm-native \
    ${PYTHON_PN}-jinja2-native \
    ${PYTHON_PN}-native \
"

# Fix python-requests
DEPENDS_class-native += "\
    ${PYTHON_PN}-ndg-httpsclient-native \
    ${PYTHON_PN}-pyasn1-native \
    ${PYTHON_PN}-pyopenssl-native \
    ${PYTHON_PN}-pysocks-native \
    ${PYTHON_PN}-urllib3-native \
    ${PYTHON_PN}-chardet-native \
    ${PYTHON_PN}-idna-native \
    ${PYTHON_PN}-certifi-native \
"

# Fix python-jinja2
DEPENDS_class-native += "\
    ${PYTHON_PN}-markupsafe-native \
"

ALTERNATIVE_${PN} += "conan"

NATIVE_LINK_NAME[conan] = "${bindir}/conan"
ALTERNATIVE_TARGET[conan] = "${bindir}/conan"

BBCLASSEXTEND = "native nativesdk"
