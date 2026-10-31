#!/bin/bash

ver="${1:-8.0.47}"
dirRoot=`dirname "$(readlink -f "$0")"`

work=`mktemp -d`
[ -f "v${ver}.tar.gz" ] || wget -qO "v${ver}.tar.gz" "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v${ver}.tar.gz"
tar -xf "v${ver}.tar.gz" --strip-components=1 -C "${work}"
cd "${work}"
[ -f "${dirRoot}/cliproxyapi-v${ver}.patch" ] && git apply "${dirRoot}/cliproxyapi-v${ver}.patch"

CGO_ENABLED=0 go build -buildvcs=false  -ldflags="-s -w -X 'main.Version=${ver}' -X 'main.Commit=$(echo ${ver} |md5sum |cut -b1-8)' -X 'main.BuildDate=$(date +%Y%m%d)'"  -o CLIProxyAPI ./cmd/server/

[ -f "./CLIProxyAPI" ] && cp -rf "./CLIProxyAPI" "${dirRoot}/cpa"
