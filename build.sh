#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  echo "MS_COMMIT=\"${MS_COMMIT}\""

  [ -f .stamp_prepared ] || . prepare_vscode.sh
  touch .stamp_prepared

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  export NODE_OPTIONS="--max-old-space-size=8192"

  [ -f .stamp_monaco-compile-check ] || yarn monaco-compile-check
  touch .stamp_monaco-compile-check
  [ -f .stamp_valid-layers-check ] || yarn valid-layers-check
  touch .stamp_valid-layers-check

  [ -f .stamp_compile-build ] || yarn gulp compile-build
  touch .stamp_compile-build
  [ -f .stamp_compile-extension-media ] || yarn gulp compile-extension-media
  touch .stamp_compile-extension-media
  [ -f .stamp_compile-extensions-build ] || yarn gulp compile-extensions-build
  touch .stamp_compile-extensions-build
  [ -f .stamp_minify-vscode ] || yarn gulp minify-vscode
  touch .stamp_minify-vscode

  if [[ "${OS_NAME}" == "osx" ]]; then
    yarn gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"

    find "../VSCode-darwin-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

    VSCODE_PLATFORM="darwin"
  elif [[ "${OS_NAME}" == "windows" ]]; then
    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      . ../build/windows/rtf/make.sh

      yarn gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

      if [[ "${VSCODE_ARCH}" != "x64" ]]; then
        SHOULD_BUILD_REH="no"
        SHOULD_BUILD_REH_WEB="no"
      fi
    fi

    VSCODE_PLATFORM="win32"
  else # linux
    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      [ -f .stamp_vscode-linux-${VSCODE_ARCH}-min-ci ] || yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"
      touch .stamp_vscode-linux-${VSCODE_ARCH}-min-ci

      find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c
    fi

    VSCODE_PLATFORM="linux"
  fi

  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    [ -f .stamp_minify-vscode-reh ] || yarn gulp minify-vscode-reh
    touch .stamp_minify-vscode-reh
    [ -f .stamp_vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci ] || yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
    touch .stamp_vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci
  fi

  if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
    [ -f .stamp_minify-vscode-reh-web ] || yarn gulp minify-vscode-reh-web
    touch .stamp_minify-vscode-reh-web
    [ -f .stamp_vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci ] || yarn gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
    touch .stamp_vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci
  fi

  cd ..
fi

touch .stamp_assets
