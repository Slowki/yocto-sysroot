#!/usr/bin/bash -e

export PATH="/scripts:$PATH"

source ./oe-init-build-env /poky/build

exec "$@"