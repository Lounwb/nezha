#!/bin/sh
printf "nameserver 127.0.0.11\nnameserver 8.8.4.4\nnameserver 223.5.5.5\n" > /etc/resolv.conf
if [ -n "${PORT:-}" ] && [ -z "${NZ_LISTEN_PORT:-}" ]; then
  export NZ_LISTEN_PORT="$PORT"
fi
exec /dashboard/app
