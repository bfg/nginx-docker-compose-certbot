#!/bin/sh

exec docker compose run -it --rm --entrypoint= certbot certbot \
  --agree-tos \
  --email root@example.org \
  --webroot \
  -w /var/www/certbot \
  "$@"

# vim:shiftwidth=2 softtabstop=2 expandtab
# EOF
