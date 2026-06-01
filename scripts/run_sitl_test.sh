#!/usr/bin/env bash
set -euo pipefail

if ! command -v sim_vehicle.py >/dev/null 2>&1; then
  echo "sim_vehicle.py was not found. Install ArduPilot tools and ensure they are on PATH." >&2
  exit 1
fi

sim_vehicle.py -v ArduCopter --console --map --out=udp:127.0.0.1:14550
