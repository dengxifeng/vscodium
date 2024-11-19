#!/bin/bash -e

# export GITHUB_TOKEN=

export ELECTRON_VERSION="32.2.5"
export VSCODE_ELECTRON_TAG="v${ELECTRON_VERSION}.riscv1"
export VSCODE_ELECTRON_REPOSITORY=riscv-forks/electron-riscv-releases

export NODE_VERSION=20.16.0
export VSCODE_NODEJS_SITE=https://unofficial-builds.nodejs.org
export VSCODE_NODEJS_URLROOT=/download/release

./build/build.sh "$@"
