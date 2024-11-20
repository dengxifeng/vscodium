#!/bin/bash -e

export APP_NAME="VSCodium"
export VSCODE_ARCH="riscv64"
export SHOULD_BUILD_APPIMAGE=no
export SHOULD_BUILD_RPM=no
export CI_BUILD=no
export SKIP_ASSETS=yes
export SHOULD_BUILD_TAR=yes
export SHOULD_BUILD_DEB=yes
export SHOULD_BUILD_REH=no
export SHOULD_BUILD_REH_WEB=no

. build.env
. prepare_assets.sh
