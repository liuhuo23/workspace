#!/bin/sh
set -e
if [ -n "$NGINX_CONF" ]; then
  echo "$NGINX_CONF" > /etc/nginx/nginx.conf
fi
exec "$@"
