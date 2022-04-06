#!/bin/sh
set -e

# Question: Should we just git clone the docker install and build it?
# 1. need to be able to pass in all the flags that the installer does
# 2. Is current user part of docker user group
# 3. If docker hello-world fails, need to see why possibly
# 4. Install docker-compose if needed, or do something if it is wrong version

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# check to see if we are on the correct docker version >= 19.0.3
correct_docker_version() {
	SERVER_VERSION=$(docker version -f "{{.Server.Version}}")
	SERVER_VERSION_MAJOR=$(echo "$SERVER_VERSION"| cut -d'.' -f 1)
	SERVER_VERSION_MINOR=$(echo "$SERVER_VERSION"| cut -d'.' -f 2)
	SERVER_VERSION_BUILD=$(echo "$SERVER_VERSION"| cut -d'.' -f 3)

	if [ "${SERVER_VERSION_MAJOR}" -ge 19 ] && \
		 [ "${SERVER_VERSION_MINOR}" -ge 0 ]  && \
		 [ "${SERVER_VERSION_BUILD}" -ge 3 ]; then
			true
	else
			false
	fi
}

# check to see if we are on the correct docker-compose version = 1.29.2
correct_compose_version() {
  COMPOSE_VERSION=$(docker-compose version --short)
  
  if [ "${COMPOSE_VERSION}" = "1.29.2" ]; then
		true
	else
		false
	fi
}

# Check for docker and do what is needed
if command_exists docker; then
  echo "Checking current docker version"
  if correct_docker_version; then
    echo "Correct docker version is installed"
  else
    echo "Legacy docker version is installed, @todo what we need to do"
    exit 1
  fi
else
  echo "Installing Docker"
  sh install.sh
fi

# Check for docker-compose and do what is needed
if command_exists docker-compose; then
  if correct_compose_version; then
		echo "Correct docker-compose version is installed"
	else
		echo "Wrong docker compose version is installed, @todo what we need to do"
	fi
else
  echo "Installing Docker-compose"
fi

# Verify that we can at least get version output
if ! docker --version; then
	echo "ERROR: Did Docker get installed?"
	exit 1
fi

# Attempt to run a container if not in a container
if [ ! -f /.dockerenv  ]; then
	if ! docker run --rm hello-world; then
		echo "ERROR: Could not get docker to run the hello world container"
		exit 2
	fi
fi

echo "INFO: Successfully verified docker installation!"