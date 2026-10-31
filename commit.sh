#!/bin/sh

apk add --no-cache tzdata openssl
cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
mkdir -p /etc/nginx /var/lib/nginx

[ -f /mnt/cpa ] && cp -rf /mnt/cpa /usr/local/bin/
[ -f /mnt/usage ] && cp -rf /mnt/usage /usr/local/bin/
[ -f /mnt/nginx ] && cp -rf /mnt/nginx /usr/local/bin/
[ -f /mnt/nginx.conf ] && cp -rf /mnt/nginx.conf /etc/nginx/

[ -f /mnt/run.sh ] && cp -rf /mnt/run.sh /run.sh
chmod -R 777 /usr/local/bin /etc/nginx /run.sh
find /var -type f -delete
echo >$HOME/.ash_history
