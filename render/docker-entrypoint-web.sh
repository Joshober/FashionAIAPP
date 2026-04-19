#!/bin/sh
set -eu
port="${PORT:-8080}"
sed "s/__PORT__/${port}/g" /etc/nginx-site.conf.tmpl > /etc/nginx/conf.d/default.conf
exec nginx -g "daemon off;"
