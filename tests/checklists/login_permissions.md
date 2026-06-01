# Login And Role Permissions

- Fresh launch creates only the default admin account.
- Login fails for incorrect password.
- Successful login writes an audit event.
- Logout writes an audit event.
- Admin can see Home, Fly, Plan, Setup, and Settings.
- Test Pilot visibility follows `PermissionManager` assignments.
- User visibility is limited to assigned minimum screens.
- Commands and settings are disabled when permission is missing.
- Admin permission changes write audit events.
