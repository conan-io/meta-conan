S = "${WORKDIR}"
export CONAN_USER_HOME = "${WORKDIR}"
export CONAN_NON_INTERACTIVE = "1"
export CONAN_REVISIONS_ENABLED = "1"

DEPENDS += " python3-conan-native"

# Need this because we do not use GNU_HASH in the conan builds
# INSANE_SKIP:${PN} = "ldflags"

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

do_install[network] = "1"
conan_do_install() {
    rm -rf ${WORKDIR}/.conan
    if [ ${CONAN_CONFIG_URL} ]; then
        echo "Installing Conan configuration from:"
        echo ${CONAN_CONFIG_URL}
        conan config install ${CONAN_CONFIG_URL}
    fi
    if [ "${CONAN_REMOTE_URL}" ]; then
        num_of_urls=$( echo ${CONAN_REMOTE_URL} | wc -w )
        num_of_names=$( echo ${CONAN_REMOTE_NAME} | wc -w )
        if [ ${num_of_urls} -ne ${num_of_names} ]; then
            echo "ERROR: number of CONAN_REMOTE_URLs does not equal number of CONAN_REMOTE_NAMEs"
            echo "${num_of_urls} CONAN_REMOTE_URLs given"
            echo "${num_of_names} CONAN_REMOTE_NAMEs given"
            exit 1
        fi
        echo "Configuring the Conan remote:"
        awk 'BEGIN{split("${CONAN_REMOTE_NAME}",a) split("${CONAN_REMOTE_URL}", b); for (i in a)
            system("conan remote add " a[i] " " b[i]) }'
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
    conan profile show -pr ${CONAN_PROFILE_PATH}

    if [ "${CONAN_USER}" ]; then
        for NAME in ${CONAN_REMOTE_NAME}
        do
            conan remote login -p "${CONAN_PASSWORD}" "${NAME}" "${CONAN_USER}"
        done
    fi
    conan install --requires=${CONAN_PKG} --profile ${CONAN_PROFILE_PATH} -of ${D}
    rm -f ${D}/deploy_manifest.txt
    rm -f ${D}/deactivate_*.sh
    rm -f ${D}/conan*.sh
}

EXPORT_FUNCTIONS do_compile do_install
