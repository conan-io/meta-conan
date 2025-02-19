SUMMARY = "Conan C/C++ package manager"
HOMEPAGE = "https://conan.io"
AUTHOR = "JFrog LTD <info@conan.io>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=1e486b3d16485847635c786d2b7bd32a"

SRC_URI[md5sum] = "c818bd5e4979093ac9fc9c7c988976a8"
SRC_URI[sha256sum] = "b09ff3d7fe8101e3ef55fd0785ae9ffbcd9237ac427da88c975e8c52908ed4f7"

inherit setuptools3 python3-dir pypi update-alternatives

# INFO: Overwrite the script to disable run-time dependency checking

do_install:append(){
    rm "${D}${bindir}/conan"
    cat >> "${D}${bindir}/conan" <<EOF
#!/usr/bin/env ${PYTHON_PN}
from conans.conan import run
run()
EOF
    chmod 755 "${D}${bindir}/conan"
}

RDEPENDS:${PN} = "\
    python3-requests \
    python3-urllib3 \
    python3-dateutil \
    python3-colorama \
    python3-pyyaml \
    python3-patch-ng \
    python3-fasteners \
    python3-distro \
    python3-jinja2 \
"

DEPENDS:class-native = "\
    python3-requests-native \
    python3-urllib3-native \
    python3-dateutil \
    python3-colorama-native \
    python3-pyyaml-native \
    python3-patch-ng-native \
    python3-fasteners-native \
    python3-distro-native \
    python3-jinja2-native \
    python3-native \
"

ALTERNATIVE:${PN} += "conan"

NATIVE_LINK_NAME[conan] = "${bindir}/conan"
ALTERNATIVE_TARGET[conan] = "${bindir}/conan"

BBCLASSEXTEND = "native nativesdk"

do_install:append:class-native() {
    sed -i -e 's|^#!.*/usr/bin/env ${PYTHON_PN}|#! /usr/bin/env nativepython3|' "${D}${bindir}/conan"
}
