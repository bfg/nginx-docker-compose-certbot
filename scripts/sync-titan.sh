#!/bin/sh

REMOTE_ENDPOINT="user@host.example.org"

die() {
  echo "FATAL: $@" 1>&2
  exit 1
}

test "$1" = "-h" -o "$1" = "--help" && {
  cat <<EOF
Usage: $0 <directory to sync>

This script syncs some directory with $REMOTE_ENDPOINT

EOF
  exit 0
}

test -z "$1" -o ! -d "$1" && die "unspecified directory sync directory: $1"
cd "$1" || die "can't enter directory: $1"

exec rsync -avr \
    --delete \
    --exclude=".idea**" \
    --exclude="tmp/**" \
    --exclude="**/data/certbot/**" \
    . \
    "$REMOTE_ENDPOINT"

# vim:shiftwidth=2 softtabstop=2 expandtab
# EOF
