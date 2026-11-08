#!/bin/sh

arch="${1:-}"
apk add --no-cache tzdata openssl
cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
mkdir -p /etc/nginx /var/lib/nginx

[ -f /mnt/${arch}/cpa ] && cp -rf /mnt/${arch}/cpa /usr/local/bin/
[ -f /mnt/${arch}/usage ] && cp -rf /mnt/${arch}/usage /usr/local/bin/
[ -f /mnt/${arch}/nginx ] && cp -rf /mnt/${arch}/nginx /usr/local/bin/
[ -f /mnt/nginx.conf ] && cp -rf /mnt/nginx.conf /etc/nginx/

[ -f /mnt/run.sh ] && cp -rf /mnt/run.sh /run.sh
chmod -R 777 /usr/local/bin /etc/nginx /run.sh
find /var -type f -delete
echo >$HOME/.ash_history
