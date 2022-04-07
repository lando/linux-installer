#!/bin/sh
set -e

# This script is meant to install dependencies needed to install docker

# Loads our functions used in this script
. ./scripts/functions.sh

if is_wsl; then
	echo
	echo "WSL DETECTED: We recommend using Docker Desktop for Windows."
	echo "Please get Docker Desktop from https://www.docker.com/products/docker-desktop"
	echo
	exit 2
fi

for PACKAGE in curl nano
do
  if command_exists ${PACKAGE}; then
    echo "$PACKAGE is installed"
  else
    echo
    echo "$PACKAGE is not installed, installing..."
    echo

    # perform some very rudimentary platform detection
    lsb_dist=$( get_distribution )
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

    # install package as need be
    case "$lsb_dist" in
      ubuntu|debian|raspbian|pop)
        sudo apt install -y ${PACKAGE}
      ;;

      centos|fedora|rhel)
        if [ "$lsb_dist" = "fedora" ]; then
          sudo dnf install -y ${PACKAGE}
        else
          sudo yum install -y ${PACKAGE}
        fi
      ;;

      sles)
        sudo zypper install -y ${PACKAGE}
      ;;

      *)
        echo "ERROR: Unsupported distribution '$lsb_dist'"
      ;;
    esac
  fi
done
