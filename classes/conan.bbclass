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

PV = "0.3.0"
LICENSE = "MIT"
DEPENDS:append = " python3-conan-native"
S = "${WORKDIR}"
# INFO: Use /usr/local to avoid conflicts with system packages
prefix = "${base_prefix}/usr/local"

CONAN_HOME="${TMPDIR}/.conan2"
CONAN_LOGLEVEL ?= "status"
CONAN_DEFAULT_PROFILE="${CONAN_HOME}/profiles/meta_build"
CONAN_REMOTE_URL ?= ""
CONAN_REMOTE_NAME ?= ""
CONAN_PROFILE_BUILD_PATH ?= "${CONAN_HOME}/profiles/meta_build"
CONAN_PROFILE_HOST_PATH ?= "${CONAN_HOME}/profiles/meta_host"
CONAN_SETTINGS_COMPILER_CPPSTD ?= "gnu17"
CONAN_SETTINGS_COMPILER_LIBCXX ?= "libstdc++11"
CONAN_CONFIG_URL ?= ""
CONAN_PROFILE_HOST_OPTIONS ?= "*/*:shared=True"
CONAN_BUILD_POLICY ?= "never"
CONAN_SETTINGS_BUILD_TYPE ?= "${@'Debug' if d.getVar('DEBUG_BUILD') == '1' else 'Release'}"
CONAN_EXTRA_CFLAGS ?= ""
CONAN_EXTRA_CXXFLAGS ?= ""

export CONAN_HOME
export CONAN_LOG_LEVEL="${CONAN_LOGLEVEL}"
export CONAN_DEFAULT_PROFILE

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

def convert_flags_to_list(d, flags):
    if not flags:
        return "[]"
    flag_list = flags.split()
    quoted_flags = [f'\\"{flag}\\"' for flag in flag_list]
    result = f'[{", ".join(quoted_flags)}]'
    return str(result)

do_configure[network] = "1"
conan_do_configure() {
    bbnote "Creating Conan home directory: ${CONAN_HOME}"
    mkdir -p "${CONAN_HOME}"

    bbnote "Creating Conan configuration"
    printf "core:non_interactive=1\n" > "${CONAN_HOME}/conan.conf"
    printf "core:default_build_profile=${CONAN_PROFILE_BUILD_PATH}\n" >> "${CONAN_HOME}/conan.conf"
    printf "core:default_profile=${CONAN_PROFILE_HOST_PATH}\n" >> "${CONAN_HOME}/conan.conf"

    if [ -n "${CONAN_CONFIG_URL}" ]; then
        bbnote "Installing Conan configuration from: ${CONAN_CONFIG_URL}"
        conan config install "${CONAN_CONFIG_URL}"
    else
        bbnote "No Conan configuration URL provided, using Conan local cache."
    fi

    echo "INFO: Configuring Conan remotes"
    if [ -n "${CONAN_REMOTE_URL}" ]; then
        urls_size=$( echo ${CONAN_REMOTE_URL} | wc -w )
        names_size=$( echo ${CONAN_REMOTE_NAME} | wc -w )
        bbdebug "Conan remote URLs size: ${urls_size}"
        bbdebug "Conan remote names size: ${names_size}"
        if [ "${urls_size}" -ne "${names_size}" ]; then
            bbfatal "Number of CONAN_REMOTE_URL (${urls_size}) does not equal number of CONAN_REMOTE_NAME (${names_size}).\nPlease, use empty space as separator for both variables."
            exit 1
        fi
        awk 'BEGIN{split("${CONAN_REMOTE_NAME}",a) split("${CONAN_REMOTE_URL}", b); for (i in a)
            system("conan remote add --force --index=0 " a[i] " " b[i]) }'
    else
        bbnote "No Conan remotes provided (CONAN_REMOTE_URL), using Conan default remotes."
    fi
    cc_major=$(${CC} -dumpfullversion | cut -d'.' -f1)
    cc_name=$(echo ${CC} | cut -d' ' -f1)
    cxx_name=$(echo ${CXX} | cut -d' ' -f1)

    bbnote "Generating build profile for ${CONAN_PROFILE_BUILD_PATH}"
    conan profile detect -f --name="${CONAN_PROFILE_BUILD_PATH}"

    bbnote "Generating host profile for ${CONAN_PROFILE_HOST_PATH}"
    formatted_cflags="${@convert_flags_to_list(d, '${CONAN_EXTRA_CFLAGS}')}"
    formatted_cxxflags="${@convert_flags_to_list(d, '${CONAN_EXTRA_CXXFLAGS}')}"
    cat > "${CONAN_PROFILE_HOST_PATH}" <<EOF
[settings]
os=Linux
arch=${@map_yocto_arch_to_conan_arch(d, 'HOST_ARCH')}
compiler=gcc
compiler.version=${cc_major}
compiler.libcxx=${CONAN_SETTINGS_COMPILER_LIBCXX}
compiler.cppstd=${CONAN_SETTINGS_COMPILER_CPPSTD}
build_type=${CONAN_SETTINGS_BUILD_TYPE}
[options]
${CONAN_PROFILE_HOST_OPTIONS}
[conf]
tools.build:cxxflags=${formatted_cxxflags}
tools.build:cflags=${formatted_cflags}
EOF

    bbnote "Profile configuration:"
    conan profile show -pr:h="${CONAN_PROFILE_HOST_PATH}" -pr:b="${CONAN_PROFILE_BUILD_PATH}"

    for remote_name in ${CONAN_REMOTE_NAME}; do
        echo "INFO: Logging in to remote '${remote_name}'"
        remote_name_upper=$(echo "${remote_name}" | tr '[a-z]' '[A-Z]' | tr '-' '_')
        if [ -z "${CONAN_LOGIN_USERNAME}" ]; then
            bbfatal "No username provided for remote '${remote_name}'. Please set CONAN_LOGIN_USERNAME."
            exit 1
        fi
        if [ -z "${CONAN_PASSWORD}" ]; then
            bbfatal "No password provided for remote '${remote_name}'. Please set CONAN_PASSWORD_${remote_name_upper} or CONAN_PASSWORD."
            exit 1
        fi

        bbnote "Logging in to remote '${remote_name}' as '${CONAN_LOGIN_USERNAME}'"
        conan remote login -p "${CONAN_PASSWORD}" "${remote_name}" "${CONAN_LOGIN_USERNAME}"
    done
}

do_compile[network] = "1"
conan_do_compile() {
    bbnote "Building package ${CONAN_PKG}"
    conan install --update --requires=${CONAN_PKG} \
        -pr:h="${CONAN_PROFILE_HOST_PATH}" \
        -pr:b="${CONAN_PROFILE_BUILD_PATH}" \
        --build=${CONAN_BUILD_POLICY}
}

conan_do_install() {
    # TODO: Move to Conan runtime_deploy after having it fixed and copying symlinks
    conan install -nr --requires=${CONAN_PKG} \
        -pr:h="${CONAN_PROFILE_HOST_PATH}" \
        -pr:b="${CONAN_PROFILE_BUILD_PATH}" \
        --deployer=full_deploy \
        --deployer-folder=${S}/deploy

    if [ -n "$(find ${S}/deploy -name '*.so*')" ]; then
        install -d ${D}${libdir}
        find ${S}/deploy -name '*.so*' -exec mv {} ${D}${libdir}/ \;
    fi

    if [ -n "$(find ${S}/deploy -type d -name 'bin')" ]; then
        install -d ${D}${bindir}
        for bin in $(find ${S}/deploy -type d -name 'bin'); do
            mv ${bin}/* ${D}${bindir}/
        done
    fi

    install -d ${D}/etc/ld.so.conf.d
    printf "${prefix}/lib\n" > ${D}/etc/ld.so.conf.d/conan.conf
}

conan_do_clean() {
    if [ "${CLEAN_CONAN_CACHE}" = "1" ]; then
        bbnote "Cleaning Conan cache..."
        conan cache clean
    fi
}

FILES:${PN} += "${prefix}/lib/* ${prefix}/bin/*"
EXPORT_FUNCTIONS do_configure do_compile do_install do_clean