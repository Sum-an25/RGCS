# MAVLink SITL Connection

- Start ArduPilot SITL with `scripts/run_sitl_test.sh`.
- Configure RGCS for UDP `127.0.0.1:14550`.
- Connect and verify heartbeat transitions link status to healthy.
- Verify telemetry updates at UI-safe frequency.
- Disconnect and verify commands become disabled.
- Reconnect without restarting RGCS.
- Confirm malformed packets do not block the UI thread.
