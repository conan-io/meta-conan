# conan.bbclass
#
# Yocto Project bbclass for Conan.io package manager
#
# This bbclass provides the integration of Conan.io into the Yocto Project
#
# Please open an issue on the GitHub repository if you encounter any problems:
#
# GitHub Repository: https://github.com/conan-io/meta-conan
# Issues: https://github.com/conan-io/meta-conan/issues

PV = "0.2.0"
LICENSE = "MIT"
DEPENDS:append = " python3-conan-native"
S = "${WORKDIR}"

export CONAN_HOME="${WORKDIR}/.conan"
export CONAN_DEFAULT_PROFILE="${CONAN_HOME}/profiles/meta_build"

# Need this because we do not use GNU_HASH in the conan builds
# INSANE_SKIP:${PN} = "ldflags"

CONAN_REMOTE_URL ?= ""
CONAN_REMOTE_NAME ?= "conan-yocto"
CONAN_PROFILE_BUILD_PATH ?= "${CONAN_HOME}/profiles/meta_build"
CONAN_PROFILE_HOST_PATH ?= "${CONAN_HOME}/profiles/meta_host"
CONAN_CONFIG_URL ?= ""
CONAN_PROFILE_HOST_OPTIONS ?= ""
CONAN_BUILD_POLICY ?= "never"

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
    bb.note("\nINFO: Arch value '{}' from '{}' mapped to '{}'".format(arch, arch_var, ret))
    return ret

do_install[network] = "1"
conan_do_install() {
    echo "INFO: Creating Conan home directory: ${CONAN_HOME}"
    rm -rf "${CONAN_HOME}"
    mkdir -p "${CONAN_HOME}"
    echo "INFO: Creating Conan configuration"
    echo 'core:non_interactive=1' > "${CONAN_HOME}/global.conf"
    if [ -n "${CONAN_CONFIG_URL}" ]; then
        echo "Installing Conan configuration from: ${CONAN_CONFIG_URL}"
        conan config install "${CONAN_CONFIG_URL}"
    else
        echo "WARN: No Conan configuration URL provided, using Conan local cache."
    fi

    echo "INFO: Configuring Conan remotes"
    if [ -n "${CONAN_REMOTE_URL}" ]; then
        urls_size=$( echo ${CONAN_REMOTE_URL} | wc -w )
        names_size=$( echo ${CONAN_REMOTE_NAME} | wc -w )
        echo "INFO: URLS SIZE: ${urls_size}"
        echo "INFO: NAMES SIZE: ${names_size}"
        if [ "${urls_size}" -ne "${names_size}" ]; then
            echo "ERROR: number of CONAN_REMOTE_URL does not equal number of CONAN_REMOTE_NAME"
            echo "CONAN_REMOTE_URL size: ${urls_size}"
            echo "CONAN_REMOTE_NAME size: ${names_size}"
            echo "Please, use empty space as separator for both variables."
            exit 1
        fi
        awk 'BEGIN{split("${CONAN_REMOTE_NAME}",a) split("${CONAN_REMOTE_URL}", b); for (i in a)
            system("conan remote add --force --index=0 " a[i] " " b[i]) }'
    else
        echo "WARN: No Conan remotes provided (CONAN_REMOTE_URL), using Conan default remotes."
    fi
    build_type="Release"
    if [ "${DEBUG_BUILD}" -eq "1" ]; then
        build_type="Debug"
    fi
    cc_major=$(${CC} -dumpfullversion | cut -d'.' -f1)
    cc_name=$(echo ${CC} | cut -d' ' -f1)
    cxx_name=$(echo ${CXX} | cut -d' ' -f1)

    # TODO: libcxx and cppstd should be configurable
    libcxx="libstdc++11"
    cppstd="gnu17"
    echo "INFO: Generating build profile"
    conan profile detect --name="${CONAN_PROFILE_BUILD_PATH}"
    echo "INFO: Generating host profile"
    cat > "${CONAN_PROFILE_HOST_PATH}" <<EOF
[settings]
os=Linux
arch=${@map_yocto_arch_to_conan_arch(d, 'HOST_ARCH')}
compiler=gcc
compiler.version=${cc_major}
compiler.libcxx=${libcxx}
compiler.cppstd=${cppstd}
build_type=${build_type}
[options]
${CONAN_PROFILE_HOST_OPTIONS}
EOF

    echo "INFO: Using build profile: ${CONAN_PROFILE_BUILD_PATH}"
    echo "INFO: Using host profile: ${CONAN_PROFILE_HOST_PATH}"
    conan profile show -pr:h="${CONAN_PROFILE_HOST_PATH}" -pr:b="${CONAN_PROFILE_BUILD_PATH}"

    for remote_name in ${CONAN_REMOTE_NAME}; do
        remote_name_upper=$(echo "${remote_name}" | tr '[a-z]' '[A-Z]' | tr '-' '_')
        if [ -z "${CONAN_LOGIN_USERNAME}" ]; then
            echo "ERROR: No username provided for remote '${remote_name}'."
            echo "Please set CONAN_LOGIN_USERNAME."
            exit 1
        fi
        if [ -z "${CONAN_PASSWORD}" ]; then
            echo "ERROR: No password provided for remote '${remote_name}'."
            echo "Please set CONAN_PASSWORD_${remote_name_upper} or CONAN_PASSWORD."
            exit 1
        fi

        echo "INFO: Logging in to remote '${remote_name}' as '${CONAN_LOGIN_USERNAME}'"
        conan remote login -p "${CONAN_PASSWORD}" "${remote_name}" "${CONAN_LOGIN_USERNAME}"
    done

    # TODO: Generate a conanfile.txt with all dependencies
    # TODO: Generators and Deploy ???
    echo "INFO: Installing packages for ${CONAN_PKG}"
    conan install --requires="${CONAN_PKG}" -pr:h="${CONAN_PROFILE_HOST_PATH}" -pr:b="${CONAN_PROFILE_BUILD_PATH}" --build="${CONAN_BUILD_POLICY}" -of "${D}"
    rm -f ${D}/deploy_manifest.txt
    rm -f ${D}/deactivate_*.sh
    rm -f ${D}/conan*.sh
}

EXPORT_FUNCTIONS do_compile do_install
