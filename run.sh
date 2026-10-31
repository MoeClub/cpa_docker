#!/bin/sh
set -eu

export TZ=`printenv TZ`
[ -z "$TZ" ] && TZ="Asia/Shanghai"
export CONFIG=`printenv CONFIG`
[ -z "$CONFIG" ] && CONFIG="/mnt/config.yaml"
export PASSWD=`printenv PASSWD`
[ -z "$PASSWD" ] && {
  _PASSWD=`cat "${CONFIG}" 2>/dev/null |grep 'secret-key:' |cut -d'"' -f2`
  echo "$_PASSWD" |grep -q '^\$' || PASSWD="${_PASSWD}"
}
[ -z "$PASSWD" ] && PASSWD=`LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8`
echo "Password: ${PASSWD}"

[ ! -f "${CONFIG}" ] && echo "Error: not found '${CONFIG}'"

sed -i \
  -e 's/^  host:.*/  host: 127.0.0.1/' \
  -e 's/^  port:.*/  port: 8317/' \
  -e 's/^  trusted-proxies:.*/  trusted-proxies: ["127.0.0.1"]/' \
  -e 's/^  allow-remote:.*/  allow-remote: true/' \
  -e 's/^  secret-key:.*/  secret-key: ""/' \
  "${CONFIG}"

MANAGEMENT_PASSWORD="${PASSWD}" /usr/local/bin/cpa --config "${CONFIG}" 2>&1 &
CPA_MANAGEMENT_KEY="${PASSWD}" LOGIN_PASSWORD="${PASSWD}" WORK_DIR="/mnt/usage.d" APP_BASE_PATH="/usage" CPA_PUBLIC_URL="/management.html" APP_HOST="127.0.0.1" APP_PORT="8318" /usr/local/bin/usage 2>&1 &
mkdir -p /var/lib/nginx/body /var/lib/nginx/fastcgi /var/lib/nginx/proxy /var/lib/nginx/scgi /var/lib/nginx/uwsgi
[ -f /mnt/nginx.conf ] && exec /usr/local/bin/nginx -c /mnt/nginx.conf -g 'daemon off; master_process on;' ||  exec /usr/local/bin/nginx -g 'daemon off; master_process on;'
