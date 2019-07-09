inherit setuptools python-dir
require python-tqdm.inc

RDEPENDS_${PN} += "\
    ${PYTHON_PN}-contextlib \
    ${PYTHON_PN}-subprocess \
"