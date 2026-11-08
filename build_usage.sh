#!/bin/bash

ver="${1:-2.0.3}"
dirRoot=`dirname "$(readlink -f "$0")"`

work=`mktemp -d`
[ -f "/tmp/usage_v${ver}.tar.gz" ] || wget -qO "/tmp/usage_v${ver}.tar.gz" "https://github.com/Willxup/cpa-usage-keeper/archive/refs/tags/v${ver}.tar.gz"
tar -xf "/tmp/usage_v${ver}.tar.gz" --strip-components=1 -C "${work}"
cd "${work}"
[ -f "${dirRoot}/usage-v${ver}.patch" ] && git apply "${dirRoot}/usage-v${ver}.patch"

docker run --rm --entrypoint /bin/sh -v "${work}:/mnt" -w "/mnt/web" ocserv/jsdom -lc 'node -v && npm -v && npm ci && npm run build'

for arch in amd64 arm64; do
  CGO_ENABLED=0 GOOS=linux GOARCH="${arch}" go build -buildvcs=false  -ldflags="-s -w -X 'cpa-usage-keeper/internal/version.Version=${ver}'" -o "usage_${arch}" ./cmd/server/main.go
  [ -f "./usage_${arch}" ] && mkdir -p "${dirRoot}/${arch}" && cp -rf "./usage_${arch}" "${dirRoot}/${arch}/usage"
done

