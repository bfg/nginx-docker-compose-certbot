#!/bin/sh

SCRIPT_DIR=$(cd -- "$( dirname -- "$0")" &> /dev/null && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")
SYNC_SCRIPT=""

die() {
  echo "FATAL: $@" 1>&2
  exit 1
}


check_sync_script() {
  local script="$1"
  if [ -f "$script" -a -x "$script" ]; then
    echo "$script"
    return 0
  fi
  return 1
}

set_sync_script() {
  local script="$1"
  test -z "$script" && die "no sync script has been specified."

  local prefix=""
  for prefix in "" "${SCRIPT_DIR}/"; do
    local file="${prefix}${script}"
    if [ -f "$file" -a -x "$file" ]; then
      SYNC_SCRIPT="$file"
      return 0
    fi
  done

  die "can't use sync script: $script"
}

test "$1" = "-h" -o "$1" = "--help" && {
  cat <<EOF
Usage: $0 <script>

This script monitors changes on filesystem using fswatch and runs specified script upon file change

EXAMPLE:

$0 sync-titan.sh
EOF
  exit 0
}

set_sync_script "$1"
cd "$BASE_DIR" || die "can't enter directory: $BASE_DIR"

echo "syncing $BASE_DIR using script $SYNC_SCRIPT"
fswatch -o -r "$BASE_DIR" | xargs -n1 "$SYNC_SCRIPT" "$BASE_DIR"

# vim:shiftwidth=2 softtabstop=2 expandtab
# EOF
