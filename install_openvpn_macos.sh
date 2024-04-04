#!/bin/bash
##############################################################################
# Copyright (c)                                                              #
# Contributor(s) : MMBAZM                                      #
#                                                                            #
# This program is free software; you can redistribute it and/or modify it    #
# under the terms of the license (GNU LGPL) which comes with this code.      #
##############################################################################

# Default target version
target_version="2.4.7"

# Check if a target version is provided as a command-line argument
if [ $# -gt 0 ]; then
    target_version="$1"
fi

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
  echo -e [$(date +"%D %T")] "\t\t"$*
}

# Check if OpenVPN is already installed and its version
installed_version=$(get_openvpn_version)

if [ "$installed_version" == "null" ] || [ "$installed_version" != "$target_version" ]; then

    info "Installing OpenVPN  ${target_version} ..."
    brew install --force openvpn@"${target_version}"
    info "Installation of OpenVPN  ${target_version} is terminated successfully."

else
    info "OpenVPN version ${target_version} is already installed."
fi