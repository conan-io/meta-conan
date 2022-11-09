SUMMARY = "Conan C/C++ package manager"
HOMEPAGE = "https://conan.io"
AUTHOR = "JFrog LTD <luism@jfrog.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=1e486b3d16485847635c786d2b7bd32a"

SRC_URI[md5sum] = "fa77ba5ea986075a12b5eb62bb65f93c"
SRC_URI[sha256sum] = "338e0cd9b814bc36f9c01bc9cc535629786abaa8a67759526aa08c329a219a24"

inherit setuptools3 python3-dir pypi update-alternatives

# Overwrite the script to disable run-time dependency checking
do_install:append(){
    rm ${D}${bindir}/conan
    cat >> ${D}${bindir}/conan <<EOF
#!/usr/bin/env ${PYTHON_PN}
from conans.conan import run
run()
EOF
    chmod 755 ${D}${bindir}/conan
}

RDEPENDS:${PN} = "\
    python3-pyjwt \
    python3-requests \
    python3-urllib3 \
    python3-colorama \
    python3-dateutil \
    python3-pyyaml \
    python3-patch-ng \
    python3-fasteners \
    python3-six \
    python3-node-semver \
    python3-distro \
    python3-pylint \
    python3-future \
    python3-pygments \
    python3-astroid \
    python3-deprecation \
    python3-tqdm \
    python3-jinja2 \
    python3-sqlite3 \
"

DEPENDS:class-native = "\
    python3-pyjwt-native \
    python3-requests-native \
    python3-urllib3-native \
    python3-colorama-native \
    python3-dateutil-native \
    python3-pyyaml-native \
    python3-patch-ng-native \
    python3-fasteners-native \
    python3-six-native \
    python3-node-semver-native \
    python3-distro-native \
    python3-pylint-native \
    python3-future-native \
    python3-pygments-native \
    python3-astroid-native \
    python3-deprecation-native \
    python3-tqdm-native \
    python3-jinja2-native \
    python3-native \
"

ALTERNATIVE:${PN} += "conan"

NATIVE_LINK_NAME[conan] = "${bindir}/conan"
ALTERNATIVE_TARGET[conan] = "${bindir}/conan"

BBCLASSEXTEND = "native nativesdk"

do_install:append:class-native() {
        sed -i -e 's|^#!.*/usr/bin/env ${PYTHON_PN}|#! /usr/bin/env nativepython3|' ${D}${bindir}/conan
}
