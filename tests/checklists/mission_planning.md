# Mission Planning

- New Mission asks for altitude.
- First map click creates takeoff and first waypoint items.
- Later map clicks add numbered waypoints.
- Waypoint latitude, longitude, altitude, hold time, and command type are editable.
- Land at Last Waypoint appends `MAV_CMD_NAV_LAND` at the last waypoint.
- Land at Home appends `MAV_CMD_NAV_LAND` at home.
- Upload uses MAVLink Mission Protocol with retries, timeout, progress, ACK, download, and verification.
