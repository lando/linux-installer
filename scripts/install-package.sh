#!/bin/sh
set -e

if [ -z "$1" ]; then
  echo "No package supplied"
	exit 2
fi

package=$1

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

is_wsl() {
	case "$(uname -r)" in
	*microsoft* ) true ;; # WSL 2
	*Microsoft* ) true ;; # WSL 1
	* ) false;;
	esac
}

if is_wsl; then
	echo
	echo "WSL DETECTED: We recommend using Docker Desktop for Windows."
	echo "Please get Docker Desktop from https://www.docker.com/products/docker-desktop"
	echo
	exit 2
fi

if command_exists curl; then
  echo "$package is installed"
else
  echo "$package is not installed"

	# perform some very rudimentary platform detection
	lsb_dist=$( get_distribution )
	lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

	# install package as need be
	case "$lsb_dist" in
		ubuntu|debian|raspbian|pop)
			sudo apt install -y ${package}
		;;

		centos|fedora|rhel)
			if [ "$lsb_dist" = "fedora" ]; then
				sudo dnf install -y ${package}
			else
				sudo yum install -y ${package}
			fi
		;;

		sles)
			sudo zypper install -y ${package}
		;;

		*)
			echo "ERROR: Unsupported distribution '$lsb_dist'"
		;;
	esac

fi
