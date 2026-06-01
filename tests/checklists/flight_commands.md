# Flight Commands

- Arm requires confirmation and a connected vehicle.
- Disarm requires confirmation and permission.
- Takeoff asks for altitude.
- RTL and Land require confirmation.
- Start Mission and Pause check role permission.
- Rejected commands show a result and write audit logs.
- Accepted commands wait for `COMMAND_ACK` in the MAVLink implementation.
