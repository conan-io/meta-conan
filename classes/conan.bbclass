S = "${WORKDIR}"
export CONAN_USER_HOME = "${WORKDIR}"
export CONAN_NON_INTERACTIVE = "1"
export CONAN_REVISIONS_ENABLED = "1"

DEPENDS += " python3-conan-native"

# Need this because we do not use GNU_HASH in the conan builds
# INSANE_SKIP_${PN} = "ldflags"

CONAN_REMOTE_URL ?= ""
CONAN_REMOTE_NAME ?= "conan-yocto"
CONAN_PROFILE_PATH ?= "${WORKDIR}/profiles/meta-conan_deploy"
CONAN_CONFIG_URL ?= ""


conan_do_compile() {
 :
}

def map_yocto_arch_to_conan_arch(d, arch_var):
    arch = d.getVar(arch_var)
    ret = {"aarch64": "armv8",
           "armv5e": "armv5el",
           "core2-64": "x86_64",
           "cortexa8hf-neon": "armv7hf",
           "arm": "armv7hf",
           "i586": "x86",
           "i686": "x86",
           "mips32r2": "mips",
           "mips64": "mips64",
           "ppc7400": "ppc32"
           }.get(arch, arch)
    print("Arch value '{}' from '{}' mapped to '{}'".format(arch, arch_var, ret))
    return ret

conan_do_install() {
    rm -rf ${WORKDIR}/.conan
    if [ ${CONAN_CONFIG_URL} ]; then
        echo "Installing Conan configuration from:"
        echo ${CONAN_CONFIG_URL}
        conan config install ${CONAN_CONFIG_URL}
    fi
    if [ ${CONAN_REMOTE_URL} ]; then
        echo "Configuring the Conan remote:"
        echo ${CONAN_REMOTE_URL}
        conan remote add ${CONAN_REMOTE_NAME} ${CONAN_REMOTE_URL}
    fi

    mkdir -p ${WORKDIR}/profiles
    ${CC} -dumpfullversion | {
    IFS=. read major minor patch
    cat > ${WORKDIR}/profiles/meta-conan_deploy <<EOF
[settings]
os_build=Linux
arch_build=${@map_yocto_arch_to_conan_arch(d, 'BUILD_ARCH')}
os=Linux
arch=${@map_yocto_arch_to_conan_arch(d, 'HOST_ARCH')}
compiler=gcc
compiler.version=$major
compiler.libcxx=libstdc++11
build_type=Release
EOF
    }

    echo "Using profile:"
    echo ${CONAN_PROFILE_PATH}
    conan profile show ${CONAN_PROFILE_PATH}

    conan user -p ${CONAN_PASSWORD} -r ${CONAN_REMOTE_NAME} ${CONAN_USER}
    conan install ${CONAN_PKG} --remote ${CONAN_REMOTE_NAME} --profile ${CONAN_PROFILE_PATH} -if ${D}
    rm -f ${D}/deploy_manifest.txt
}

EXPORT_FUNCTIONS do_compile do_install
