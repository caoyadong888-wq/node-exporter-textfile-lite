#!/usr/bin/env bash
# Read a service heartbeat fixture and write age and up gauges.
# Pass --now for a fixed clock. Without it, the script uses date +%s.
set -euo pipefail
here="$(cd "$(dirname -- "$0")" && pwd)"
# shellcheck source=common.sh
source "${here}/common.sh"

usage() {
  echo "usage: service_heartbeat.sh --fixture PATH --out PATH [--now EPOCH]" >&2
}

fixture=""
out=""
now=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fixture) fixture="${2:-}"; shift 2 ;;
    --out) out="${2:-}"; shift 2 ;;
    --now) now="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$fixture" || -z "$out" ]]; then
  usage
  exit 2
fi

if [[ -z "$now" ]]; then
  now="$(date +%s)"
fi
require_uint now "$now"

resolved="$(refuse_live_path "$fixture")"

format_ok=0
service=""
status=""
unix_time=""

while IFS= read -r line || [[ -n "${line:-}" ]]; do
  line="${line%$'\r'}"
  if [[ -z "$line" ]]; then
    continue
  fi
  if [[ "$line" == \#* ]]; then
    if [[ "$line" == *"fixture-format: heartbeat-v1"* ]]; then
      format_ok=1
    fi
    continue
  fi
  if [[ "$line" != *:* ]]; then
    echo "bad fixture line: $line" >&2
    exit 2
  fi
  key="$(trim "${line%%:*}")"
  val="$(trim "${line#*:}")"
  case "$key" in
    service)
      [[ -z "$service" ]] || { echo "duplicate service" >&2; exit 2; }
      service="$val"
      ;;
    status)
      [[ -z "$status" ]] || { echo "duplicate status" >&2; exit 2; }
      status="$val"
      ;;
    unix_time)
      [[ -z "$unix_time" ]] || { echo "duplicate unix_time" >&2; exit 2; }
      unix_time="$val"
      ;;
    *)
      echo "unknown key: $key" >&2
      exit 2
      ;;
  esac
done < "$resolved"

if [[ "$format_ok" -ne 1 ]]; then
  echo "missing fixture-format: heartbeat-v1" >&2
  exit 2
fi

require_match service "$service" '^[a-z][a-z0-9_-]{0,31}$'
require_uint unix_time "$unix_time"
case "$status" in
  up) up=1 ;;
  down) up=0 ;;
  *) echo "status must be up or down" >&2; exit 2 ;;
esac

age=$((10#$now - 10#$unix_time))

write_atomic "$out" <<EOF
# HELP textfile_service_heartbeat_up 1 when the fixture status is up and 0 when it is down
# TYPE textfile_service_heartbeat_up gauge
textfile_service_heartbeat_up{service="${service}",source="fixture"} ${up}
# HELP textfile_service_heartbeat_age_seconds Now minus the fixture unix_time
# TYPE textfile_service_heartbeat_age_seconds gauge
textfile_service_heartbeat_age_seconds{service="${service}",source="fixture"} ${age}
EOF
