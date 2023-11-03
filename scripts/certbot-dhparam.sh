#!/bin/sh

test "$1" = "" -o "$1" = "-h" -o "$1" = "--help" && {
  cat <<EOF
Usage: $0 <domain>

This script generates openssl dhparam for given site
EOF
  exit 0
}

out_file="/etc/letsencrypt/live/$1/dhparam.pem"
docker compose run --entrypoint= certbot \
  openssl \
  dhparam \
  -out "$out_file" \
  2048
echo "dhparam file: $out_file"

# vim:shiftwidth=2 softtabstop=2 expandtab
# EOF