#!/usr/bin/env bash

set -o errexit
set -o nounset

#
# Script state init
#
script_dir="$(cd "$(dirname "${0}")" && pwd)"
cd "${script_dir}/.."

if [ "$#" -ne 1 ]; then
    echo ""
    echo "Usage: '${0}' <version>"
    echo "       '${0}' 1.7.1"
    echo ""
    exit 1
fi

#
# Script parameters
#
version="${1}"
files_to_check=(
    "dist/tengo/software/jq-${version}.sw.json"
)

for f in "${files_to_check[@]}"; do
    if ! [ -f "${f}" ]; then
        echo ""
        echo "No entrypoint descriptor found at '${f}'."
        echo ""
        echo "Looks like you're going to publish new version of jq distribution."
        echo "See README.md for the instructions on how to do this properly."
        echo ""

        exit 1
    fi
done

pl-pkg sign packages \
    --package-id="${version}" \
    --all-platforms \
    --sign-command='["gcloud-kms-sign", "{pkg}", "{pkg}.sig"]'

pl-pkg publish packages \
    --package-id="${version}" \
    --fail-existing-packages\
    --all-platforms
