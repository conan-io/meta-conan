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

CONAN_REMOTE_URLS ?= ""
CONAN_REMOTE_NAMES ?= "conan-yocto"
CONAN_PROFILE_BUILD_PATH ?= "${CONAN_HOME}/profiles/meta_build"
CONAN_PROFILE_HOST_PATH ?= "${CONAN_HOME}/profiles/meta_host"
CONAN_CONFIG_URL ?= ""
CONAN_PROFILE_HOST_OPTIONS ?= ""

conan_do_compile() {
 :
}

do_install[network] = "1"
conan_do_install() {
    rm -rf "${CONAN_HOME}"
    if [ -n "${CONAN_CONFIG_URL}" ]; then
        echo "Installing Conan configuration from: ${CONAN_CONFIG_URL}"
        conan config install "${CONAN_CONFIG_URL}"
    else
        echo "WARN: No Conan configuration URL provided, using Conan local cache."
    fi
    if [ -n "${CONAN_REMOTE_URLS}" ]; then
        if [ ${#CONAN_REMOTE_URLS[@]} -ne ${#CONAN_REMOTE_NAMES[@]} ]; then
            echo "ERROR: number of CONAN_REMOTE_URLS does not equal number of CONAN_REMOTE_NAMES"
            echo "CONAN_REMOTE_URLS size: ${#CONAN_REMOTE_URLS[@]}"
            echo "CONAN_REMOTE_NAMES size: ${#CONAN_REMOTE_NAMES[@]}"
            echo "Please, use empty space as separator for both variables."
            exit 1
        fi
        echo "INFO: Configuring the Conan remotes: ${CONAN_REMOTE_NAMES}"
        index=0
        while [ $index -lt ${#CONAN_REMOTE_NAMES[@]} ]; do
            conan remote add --force --index=0 "${CONAN_REMOTE_NAMES[$i]}" "${CONAN_REMOTE_URLS[$i]}"
            ((index++))
        done
    else
        echo "WARN: No Conan remotes provided (CONAN_REMOTE_URLS), using Conan default remotes."
    fi
    build_type="Release"
    if [ "${DEBUG_BUILD}" = "1" ]; then
        build_type="Debug"
    fi
    cc_major=$(${CC} -dumpfullversion | cut -d'.' -f1)
    conan profile detect --name="${CONAN_PROFILE_BUILD_PATH}"

    echo "INFO: Using build profile: ${CONAN_PROFILE_BUILD_PATH}"
    echo "INFO: Using host profile: ${CONAN_PROFILE_HOST_PATH}"
    conan profile show -pr:h="${CONAN_PROFILE_HOST_PATH}" -pr:b="${CONAN_PROFILE_BUILD_PATH}"

    for remote_name in ${CONAN_REMOTE_NAMES}; do
        remote_name_upper="${remote_name^^}"
        username=''
        password=''
        if [[ -v "${CONAN_LOGIN_USERNAME}_${remote_name_upper}" ]]; then
            username="${CONAN_LOGIN_USERNAME}_${remote_name_upper}"
        elif [[ -v "${CONAN_LOGIN_USERNAME}" ]]; then
            username="${CONAN_LOGIN_USERNAME}"
        fi
        if [ -z "$username" ]; then
            echo "ERROR: No username provided for remote '${remote_name}'."
            echo "Please set CONAN_LOGIN_USERNAME or CONAN_LOGIN_USERNAME_${remote_name_upper}."
            exit 1
        fi

        if [[ -v "${CONAN_PASSWORD}_${remote_name_upper}" ]]; then
            password="${CONAN_PASSWORD}_${remote_name_upper}"
        elif [[ -v "${CONAN_PASSWORD}" ]]; then
            password="${CONAN_PASSWORD}"
        fi
        if [ -z "$password" ]; then
            echo "ERROR: No password provided for remote '${remote_name}'."
            echo "Please set CONAN_PASSWORD or CONAN_PASSWORD_${remote_name_upper}."
            exit 1
        fi

        echo "INFO: Logging in to remote '${remote_name}' as '${username}'"
        conan remote auth "${remote_name}"
    done

    # TODO: Generate a conanfile.txt with all dependencies
    echo "INFO: Installing packages for ${CONAN_PKG}"
    conan install --requires="${CONAN_PKG}" -pr:h="${CONAN_PROFILE_HOST_PATH}" -pr:b="${CONAN_PROFILE_BUILD_PATH}" -of "${D}"
    rm -f "${D}/deploy_manifest.txt"
    rm -f "${D}/deactivate_*.sh"
    rm -f "${D}/conan*.sh"
}

EXPORT_FUNCTIONS do_compile do_install
