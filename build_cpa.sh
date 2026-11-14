#!/bin/bash

ver="${1:-8.0.69}"
dirRoot=`dirname "$(readlink -f "$0")"`

work=`mktemp -d`
[ -f "/tmp/cpa_v${ver}.tar.gz" ] || wget -qO "/tmp/cpa_v${ver}.tar.gz" "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v${ver}.tar.gz"
tar -xf "/tmp/cpa_v${ver}.tar.gz" --strip-components=1 -C "${work}"
cd "${work}"
[ -f "${dirRoot}/cliproxyapi-v${ver}.patch" ] && git apply "${dirRoot}/cliproxyapi-v${ver}.patch"

for arch in amd64 arm64; do
  CGO_ENABLED=0 GOOS=linux GOARCH="${arch}" go build -buildvcs=false  -ldflags="-s -w -X 'main.Version=${ver}' -X 'main.Commit=$(echo ${ver} |md5sum |cut -b1-8)' -X 'main.BuildDate=$(date +%Y%m%d)'"  -o "CLIProxyAPI_${arch}" ./cmd/server/
  [ -f "./CLIProxyAPI_${arch}" ] && mkdir -p "${dirRoot}/${arch}" && cp -rf "./CLIProxyAPI_${arch}" "${dirRoot}/${arch}/cpa"
done
