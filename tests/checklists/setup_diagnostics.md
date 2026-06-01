# Setup And Diagnostics

- Parameter load lists vehicle parameters.
- Parameter write requires confirmation and permission.
- Parameter backup save/load/compare works offline.
- Safety values validate before write.
- Sensor calibration blocks when armed and logs the command.
- Radio calibration shows live channel min/max/trim.
- EKF diagnostics consume `EKF_STATUS_REPORT`.
- Vibration diagnostics consume `VIBRATION` and show clipping.
