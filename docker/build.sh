#!/bin/bash

readonly SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"
cd "$SCRIPT_DIR"
BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -t yocto
