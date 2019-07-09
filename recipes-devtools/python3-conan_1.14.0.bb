inherit setuptools3 python3-dir
require python-conan.inc

do_install_append_class-native() {
        sed -i -e 's|^#!.*/usr/bin/env ${PYTHON_PN}|#! /usr/bin/env nativepython3|' ${D}${bindir}/conan
}