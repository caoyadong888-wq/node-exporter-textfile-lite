#!/usr/bin/env bash
# Shared helpers for the textfile collectors. Source this file.
# It does not read block devices and it does not write a .prom file by itself.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "source this file from a collector; it is not a collector" >&2
  exit 2
fi

set -euo pipefail
umask 022

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

require_match() {
  local name="$1" value="$2" pattern="$3"
  if [[ ! "$value" =~ $pattern ]]; then
    echo "bad ${name}: ${value}" >&2
    exit 2
  fi
}

require_uint() {
  local name="$1" value="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]]; then
    echo "bad ${name}: ${value}" >&2
    exit 2
  fi
}

refuse_live_path() {
  local raw="$1" resolved first
  if [[ -z "$raw" ]]; then
    echo "empty path" >&2
    exit 2
  fi
  if ! resolved="$(readlink -f -- "$raw")"; then
    echo "cannot resolve path: $raw" >&2
    exit 2
  fi
  case "$resolved" in
    /dev|/dev/*|/sys|/sys/*|/proc|/proc/*)
      echo "refusing live device path: $resolved" >&2
      exit 2
      ;;
  esac
  if [[ -b "$resolved" || -c "$resolved" ]]; then
    echo "refusing device node: $resolved" >&2
    exit 2
  fi
  if [[ ! -f "$resolved" ]]; then
    echo "fixture not found: $resolved" >&2
    exit 2
  fi
  first="$(wc -c < "$resolved" | tr -d '[:space:]')"
  if [[ "$first" -gt 1048576 ]]; then
    echo "fixture larger than 1 MiB: $resolved" >&2
    exit 2
  fi
  printf '%s' "$resolved"
}

write_atomic() {
  local dest="$1" dir tmp
  dir="$(dirname -- "$dest")"
  mkdir -p -- "$dir"
  tmp="$(mktemp "${dir}/.partial.XXXXXX")"
  cat > "$tmp"
  chmod 644 "$tmp"
  mv -f -- "$tmp" "$dest"
}
