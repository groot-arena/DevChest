#!/usr/bin/env bash
# DevChest install entry point. Supports remote (curl/wget one-liner) and local clone.
set -euo pipefail

# Bash 4+ required
if [[ -z "${BASH_VERSINFO[0]:-}" ]] || [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  echo "[ERROR] DevChest requires Bash 4.0 or newer. Current: ${BASH_VERSION:-unknown}" >&2
  exit 1
fi

# Parse flags (before we have lib)
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "DevChest — Install development and everyday tools."
      echo "Usage: $0 [--help] [--verbose] [--keep-workdir]"
      echo "  --help          Show this help"
      echo "  --verbose       Verbose logging"
      echo "  --keep-workdir  Keep temporary directory after remote install (debug)"
      exit 0
      ;;
    --verbose)
      export DC_VERBOSE=1
      shift
      ;;
    --keep-workdir)
      export DC_KEEP_WORKDIR=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Detect remote vs local: do we have a real script path and lib/common.sh next to it?
_install_src="${BASH_SOURCE[0]:-}"
_install_dir=""
if [[ -n "${_install_src}" && "${_install_src}" != "-" && "${_install_src}" != "bash" ]]; then
  if [[ -f "${_install_src}" ]]; then
    _install_dir="$(cd "$(dirname "${_install_src}")" && pwd)"
  fi
fi

if [[ -z "${_install_dir}" ]] || [[ ! -f "${_install_dir}/lib/common.sh" ]]; then
  # Remote mode: download repo tarball and re-exec from extracted tree
  _tmp=""
  _tmp="$(mktemp -d)"
  _tarball="${_tmp}/devchest.tar.gz"
  _url="https://github.com/groot-arena/devchest/tarball/main"

  if command -v curl &>/dev/null; then
    curl -fsSL -o "${_tarball}" "${_url}"
  elif command -v wget &>/dev/null; then
    wget -q -O "${_tarball}" "${_url}"
  else
    echo "[ERROR] Need curl or wget to download DevChest. Install one and re-run." >&2
    rm -rf "${_tmp}"
    exit 1
  fi

  tar -xzf "${_tarball}" -C "${_tmp}"
  _extracted=""
  for _d in "${_tmp}"/groot-arena-devchest-*; do
    if [[ -d "${_d}" ]]; then
      _extracted="${_d}"
      break
    fi
  done
  if [[ -z "${_extracted}" ]] || [[ ! -f "${_extracted}/install.sh" ]]; then
    echo "[ERROR] Failed to extract DevChest repository." >&2
    rm -rf "${_tmp}"
    exit 1
  fi

  if [[ "${DC_KEEP_WORKDIR:-0}" -ne 0 ]]; then
    echo "[INFO] Workdir kept: ${_extracted}" >&2
  fi

  _ret=0
  bash "${_extracted}/install.sh" "$@" || _ret=$?
  if [[ "${DC_KEEP_WORKDIR:-0}" -eq 0 ]]; then
    rm -rf "${_tmp}"
  fi
  exit "${_ret}"
fi

# Local mode
cd "${_install_dir}"
# shellcheck source=lib/common.sh
source "./lib/common.sh"
# shellcheck source=lib/debian.sh
source "./lib/debian.sh"
# shellcheck source=lib/redhat.sh
source "./lib/redhat.sh"
# shellcheck source=lib/menu.sh
source "./lib/menu.sh"

dc_ensure_root_or_sudo
dc_preflight_install
dc_main_install
