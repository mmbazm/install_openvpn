#!/bin/bash
##############################################################################
# Copyright (c)                                                              #
# Contributor(s) : MMBAZM                                      #
#                                                                            #
# This program is free software; you can redistribute it and/or modify it    #
# under the terms of the license (GNU LGPL) which comes with this code.      #
##############################################################################

# Default target version
target_version="2.4.12"

# Check if a target version is provided as a command-line argument
if [ $# -gt 0 ]; then
    target_version="$1"
fi

# Variables
# URL for downloading the OpenVPN installer
openvpn_url="https://swupdate.openvpn.org/community/releases/openvpn-${target_version}.tar.gz"


# Func to check if OpenVPN is installed and its version. If already installed return the version otherwise null value
get_openvpn_version() {
    pkg_version=$(openvpn --version 2>/dev/null | head -n 1 | awk '{print $2}')
    if [ -z "$pkg_version" ]; then
        echo "null"
    else
        echo "$pkg_version"
    fi
}

# local function to log the steps of execution of the script
function info {
  echo -e [`date +"%D %T"`] "\t\t"$*
}

info "Script is running ..."
# Detect OS of platform
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep VERSION_ID /etc/os-release | cut -d '=' -f 2 | tr -d '"')
    info "[Platform-Info] --> ${os}:${os_version}"

elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oE '[0-9]+' /etc/debian_version)
    info "[Platform-Info] --> ${os}:${os_version}"

elif [[ -e /etc/centos-release ]]; then
	os="centos"
	os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release /etc/rocky-release /etc/centos-release | head -1)
    info "[Platform-Info] --> ${os}:${os_version}"

elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release)
    info "[Platform-Info] --> ${os}:${os_version}"

else
	info "/!\ unsupported distribution"
	exit
fi

# Check if OpenVPN is already installed and its version
installed_version=$(get_openvpn_version)
echo "$installed_version"
if [ -z "$installed_version" ] || [ "$installed_version" != "$target_version" ]; then

    if [ "${os}" == "ubuntu" ] || [ "${os}" == "debian" ]; then
        if [[ $os_version == "16.04" ]]; then
            	echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn.list
				wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
				apt-get update
        fi
        # Ubuntu > 16.04 and Debian > 8 have OpenVPN >= 2.4 without the need of a third party repository.
        sudo apt-get update /f >nul 2>&1
        sudo apt-get install -y openvpn="${target_version}"* openssl /f >nul 2>&1

    elif [ "$os" == "centos" ]; then
        sudo yum install -y "${target_version}"* openssl /f >nul 2>&1

    elif [ "$os" == "fedora" ]; then
        sudo dnf install openvpn-"${$target_version}"* /f >nul 2>&1

    else
        info "Unsupported version"

    fi

else
    info "OpenVPN version ${target_version} is already installed."
fi