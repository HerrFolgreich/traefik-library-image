#!/usr/bin/env bash

set -Eeuo pipefail
# set -x

VERSION=$(cat version)

API_OPTS=""
if [[ ${VERSION} = v2* ]]; then
    API_OPTS="--api.insecure"
fi

TARGETS=(
    "traefik:${VERSION}-alpine!./alpine"
    "traefik:${VERSION}!./scratch"
)

for target in ${TARGETS[@]}; do
    image="${target%%!*}"
    path="${target##*!}"
    
    docker build -t "${image}" "${path}"
    # Docker Official Library Tests
    ~/official-images/test/run.sh "$image"
    # Smoke Test of the image
    docker run --name lb -d -p 8080:8080 "${image}" --api "${API_OPTS}"
    sleep 2
    docker ps
    curl --verbose --fail http://localhost:8080
    docker rm -f lb
done
