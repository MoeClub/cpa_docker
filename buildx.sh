#!/bin/sh
set -e

withLatest="${1:-1}"
dockerProject="cpa"
dockerBase="alpine:3.21"
dockerName="${dockerProject}_buildx"
mntPath=`dirname "$(readlink -f "$0")"`
version="latest"


manifest=""
for arch in "amd64" "arm64"; do
  docker run --rm --platform "linux/${arch}" "${dockerBase}" apk --print-arch >/dev/null 2>&1 || docker run --privileged --rm tonistiigi/binfmt --install "${arch}"
  docker rm -f "${dockerName}" >/dev/null 2>&1 || true
  docker run --platform "linux/${arch}" --name "${dockerName}" -id -v "${mntPath}:/mnt" "${dockerBase}"
  docker exec "${dockerName}" /bin/sh -x /mnt/commit.sh "${arch}"
  docker commit --change 'CMD ["/bin/sh", "/run.sh"]' "${dockerName}" "${dockerProject}:${version}"
  docker rm -f "${dockerName}" >/dev/null 2>&1 || true
  userName="$(docker info 2>/dev/null |grep 'Username:' |cut -d':' -f2 |sed 's/[[:space:]]//g')"
  [ -n "$userName" ] && {
    docker tag "${dockerProject}:${version}" "${userName}/${dockerProject}_${arch}:${version}"
    docker push "${userName}/${dockerProject}_${arch}:${version}"
    [ $? -eq 0 ] && manifest=`echo "--amend \"${userName}/${dockerProject}_${arch}:${version}\" ${manifest}" |sed 's/\ \+$//'`
  }
done

[ -n "$userName" ] && [ -n "$manifest" ] && eval `echo "docker manifest create \"${userName}/${dockerProject}:${version}\" $manifest"` && docker manifest push -p "${userName}/${dockerProject}:${version}"

