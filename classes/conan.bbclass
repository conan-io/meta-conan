S = "${WORKDIR}"
export CONAN_USER_HOME = "${WORKDIR}"
export CONAN_NON_INTERACTIVE = "1"

DEPENDS += " python3-conan-native"

# Need this because we do not use GNU_HASH in the conan builds
# INSANE_SKIP_${PN} = "ldflags"

CONAN_REMOTE ?= "https://conan.bintray.com"

conan_do_compile() {
 :
}

def map_yocto_arch_to_conan_arch(d):
    target_arch = d.getVar('TUNE_ARCH')
    print("Calculating Conan architecture from: {}".format(target_arch))
    ret = {"aarch64": "armv8",
           "armv5e": "armv5el",
           "core2-64": "x86_64",
           "cortexa8hf-neon": "armv7hf",
           "arm": "armv7hf",
           "i586": "x86",
           "mips32r2": "mips",
           "mips64": "mips64",
           "ppc7400": "ppc32"
           }.get(target_arch, target_arch)
    print("Mapped to: {}".format(ret))
    return ret

CONAN_TARGET_ARCH ?= "${@map_yocto_arch_to_conan_arch(d)}"

conan_do_install() {
    rm -rf ${WORKDIR}/.conan
    mkdir -p ${WORKDIR}/profiles
    ${CC} -dumpfullversion | { 
    IFS=. read major minor patch
    cat > ${WORKDIR}/profiles/deploy <<EOF
[settings]
os_build=Linux
arch_build=${CONAN_TARGET_ARCH}
os=Linux
arch=${@map_yocto_arch_to_conan_arch(d)}
compiler=gcc
compiler.version=$major
compiler.libcxx=libstdc++11
build_type=Release
EOF
    }
    echo "Using profile:"
    cat ${WORKDIR}/profiles/deploy
    conan remote add conan-yocto ${CONAN_REMOTE}
    conan user -p ${CONAN_PASSWORD} -r conan-yocto ${CONAN_USER}
    conan install ${CONAN_PKG} --remote conan-yocto --profile ${WORKDIR}/profiles/deploy -if ${D}
    rm -f ${D}/deploy_manifest.txt
}

EXPORT_FUNCTIONS do_compile do_install
