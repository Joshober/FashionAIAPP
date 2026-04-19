#!/bin/sh
set -eu
port="${PORT:-8080}"
sed "s/__PORT__/${port}/g" /tmp/nginx-site.conf > /etc/nginx/conf.d/default.conf
exec nginx -g "daemon off;"
