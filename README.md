# RGCS

RGCS is a Qt 6/QML ground control station scaffold for ArduPilot multicopters. It is structured for a production GCS with secure local users, role-based permissions, audit logging, MAVLink transport boundaries, mission planning, telemetry models, setup workflows, video settings, and macOS/Linux packaging paths.

## Current Login

The first launch seeds a local admin account in the application data SQLite database:

- Username: `admin`
- Password: `ChangeMe123!`

Change this before using RGCS outside local development.

## Build

Requirements:

- Qt 6.5 or newer with Quick, Quick Controls 2, SQL, Location, Positioning, Multimedia, and SerialPort modules
- CMake 3.21+
- C++17 compiler

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

## Platform Scripts

- `scripts/build_macos.sh`: configures and builds a macOS bundle.
- `scripts/build_ubuntu.sh`: configures and builds on Ubuntu.
- `scripts/package_appimage.sh`: packages the Linux binary as an AppImage when `linuxdeploy` is available.
- `scripts/run_sitl_test.sh`: starts ArduPilot SITL and connects RGCS to UDP `127.0.0.1:14550`.

## Architecture

Core objects are exposed to QML through `AppController`:

- `AuthManager`
- `PermissionManager`
- `AppSettingsManager`
- `MavlinkConnectionManager`
- `TelemetryManager`
- `MissionManager`
- `CommandManager`
- `AuditLogger`
- `CoordinateConverter`

The source tree is ready for additional dedicated modules requested by the product brief, including `VehicleManager`, `ParameterManager`, `CalibrationManager`, `FailsafeManager`, `DiagnosticManager`, `VideoManager`, `MapProviderManager`, `TelemetryLogger`, and `NotificationManager`.

## MAVLink Notes

The app currently contains the transport and command/mission adapter boundaries. The next implementation step is to add generated MAVLink v2 headers and replace the marked adapter sections with:

- UDP/TCP/serial byte streams
- MAVLink v2 packet parsing on a worker thread
- handlers for heartbeat, status, battery, GPS, position, attitude, EKF, vibration, RC channels, parameters, mission protocol, and command acknowledgements
- mission upload/download retry and timeout state machines

## Test Checklists

Manual QA checklists live in `tests/checklists/`.
