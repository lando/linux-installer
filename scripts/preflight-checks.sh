#!/bin/sh
set -e

# This script is meant to install dependencies needed to install docker

# install curl if needed
set -- "curl"
. ./scripts/install-package.sh
