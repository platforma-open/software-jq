#!/usr/bin/env bash

set -o errexit
set -o nounset

script_dir="$(cd "$(dirname "${0}")" && pwd)"
cd "${script_dir}/../../"

base_url="https://github.com/jqlang/jq/releases/download"

if [ "$#" -ne 3 ]; then
    echo "Usage: '${0}' <version> <os> <arch>"
    echo "Example: '${0}' 1.7.1 linux x64"
    echo "OS list: linux, windows, macosx"
    echo "Arch list: x64, aarch64"
    exit 1
fi

version="${1}"
os="${2}"
arch="${3}"
dst_root="dld"
dst_data_dir="${dst_root}/jq-${version}-${os}-${arch}"
tmp_download_path="${dst_root}/jq-${version}-temp-download"  # New temporary download path

# Simplified arch and ext determination
case "${arch}" in
    "arm64"|"aarch64") 
        arch="arm64"
        dl_arch="arm64"
    ;;
    "amd64"|"x86_64"|"x64")
        arch="x64"
        dl_arch="amd64"
    ;;
    *) echo "Unknown arch: ${arch}"; exit 1 ;;
esac

case "${os}" in
    "macosx"|"macos") dl_os="macos";;
    "linux") dl_os="linux";;
    "windows") dl_os="windows";;
    *) echo "Unknown arch: ${os}"; exit 1 ;;
esac

case "${os}" in
    "linux"|"macosx") ext="" ;;
    "windows") ext=".exe" ;;
    *) echo "Unknown OS: ${os}"; exit 1 ;;
esac

echo "Proceeding with supported combination: ${os}, ${arch}"

log() {
    printf "%s\n" "$@"
}

download() {
    local url="${base_url}/jq-${version}/jq-${dl_os}-${dl_arch}${ext}"
    local show_progress=()

    # Only add --show-progress if CI is not set to 'true'
    if [ "${CI:-false}" != "true" ]; then
        show_progress=("--show-progress")
    fi

    log "Downloading '${url}'"
    wget --quiet "${show_progress[@]}" --output-document="${tmp_download_path}" "${url}"
}

rename() {
    log "Moving binary to '${dst_data_dir}'"

    rm -rf "${dst_data_dir}"
    mkdir -pv "${dst_data_dir}/bin"
    
    # Use the correct destination filename with extension for Windows
    if [ "${os}" = "windows" ]; then
        mv -v "${tmp_download_path}" "${dst_data_dir}/bin/jq${ext}"
    else
        mv -v "${tmp_download_path}" "${dst_data_dir}/bin/jq"
    fi
    
    # Make binary executable
    chmod +x "${dst_data_dir}/bin/jq${ext:-}"
}

mkdir -p "${dst_root}"
download
rename