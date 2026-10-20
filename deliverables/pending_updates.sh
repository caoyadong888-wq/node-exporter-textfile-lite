#!/usr/bin/env bash
# Count package lines in an apt or yum fixture. Does not run apt, yum, or dnf.
set -euo pipefail
here="$(cd "$(dirname -- "$0")" && pwd)"
# shellcheck source=common.sh
source "${here}/common.sh"

usage() {
  echo "usage: pending_updates.sh --fixture PATH --manager apt|yum --out PATH [--host NAME]" >&2
}

fixture=""
out=""
manager=""
host="example.com"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fixture) fixture="${2:-}"; shift 2 ;;
    --manager) manager="${2:-}"; shift 2 ;;
    --out) out="${2:-}"; shift 2 ;;
    --host) host="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$fixture" || -z "$out" || -z "$manager" ]]; then
  usage
  exit 2
fi

case "$manager" in
  apt) marker="fixture-format: apt-upgradable-v1" ;;
  yum) marker="fixture-format: yum-check-update-v1" ;;
  *) echo "manager must be apt or yum" >&2; exit 2 ;;
esac

require_match host "$host" '^[a-z0-9]([a-z0-9.-]{0,251}[a-z0-9])?$'
resolved="$(refuse_live_path "$fixture")"

format_ok=0
count=0
while IFS= read -r line || [[ -n "${line:-}" ]]; do
  line="${line%$'\r'}"
  line="$(trim "$line")"
  if [[ -z "$line" ]]; then
    continue
  fi
  if [[ "$line" == \#* ]]; then
    if [[ "$line" == *"$marker"* ]]; then
      format_ok=1
    fi
    continue
  fi
  if [[ "$manager" == "apt" ]]; then
    if [[ ! "$line" =~ ^[a-z0-9][a-z0-9+.-]{0,63}([[:space:]]+[A-Za-z0-9.+:~_-]+)?$ ]]; then
      echo "bad apt fixture line: $line" >&2
      exit 2
    fi
  else
    if [[ ! "$line" =~ ^[A-Za-z0-9_.+-]+\.[A-Za-z0-9_]+[[:space:]]+[A-Za-z0-9.+:~_-]+[[:space:]]+[A-Za-z0-9_.-]+$ ]]; then
      echo "bad yum fixture line: $line" >&2
      exit 2
    fi
  fi
  count=$((10#$count + 1))
done < "$resolved"

if [[ "$format_ok" -ne 1 ]]; then
  echo "missing ${marker}" >&2
  exit 2
fi

write_atomic "$out" <<EOF
# HELP textfile_pending_updates_count Package lines in the fixture file
# TYPE textfile_pending_updates_count gauge
textfile_pending_updates_count{manager="${manager}",host="${host}",source="fixture"} ${count}
EOF
