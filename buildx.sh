#!/bin/sh
set -e

withLatest="${1:-1}"
dockerProject="cpa"
dockerBase="alpine:3.21"
dockerName="${dockerProject}_buildx"
mntPath=`dirname "$(readlink -f "$0")"`
version="latest"
arch="amd64"

docker rm -f "${dockerName}" >/dev/null 2>&1 || true
docker run --platform "linux/${arch}" --name "${dockerName}" -id -v "${mntPath}:/mnt" "${dockerBase}"
docker exec "${dockerName}" /bin/sh -x /mnt/commit.sh
docker commit --change 'CMD ["/bin/sh", "/run.sh"]' "${dockerName}" "${dockerProject}:${version}"
docker rm -f "${dockerName}" >/dev/null 2>&1 || true
userName="$(docker info 2>/dev/null |grep 'Username:' |cut -d':' -f2 |sed 's/[[:space:]]//g')"
[ -n "$userName" ] && {
  docker tag "${dockerProject}:${version}" "${userName}/${dockerProject}:${version}"
  docker push "${userName}/${dockerProject}:${version}"
}
