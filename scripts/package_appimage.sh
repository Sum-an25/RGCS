#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/ubuntu"
APPDIR="${ROOT_DIR}/build/AppDir"

if ! command -v linuxdeploy >/dev/null 2>&1; then
  echo "linuxdeploy is required to create the AppImage." >&2
  exit 1
fi

"${ROOT_DIR}/scripts/build_ubuntu.sh"
rm -rf "${APPDIR}"
mkdir -p "${APPDIR}/usr/bin"
cp "${BUILD_DIR}/rgcs" "${APPDIR}/usr/bin/rgcs"

linuxdeploy --appdir "${APPDIR}" --executable "${APPDIR}/usr/bin/rgcs" --output appimage
