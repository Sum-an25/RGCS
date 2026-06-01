#pragma once

// Product module map. Dedicated implementations should graduate from this
// catalog as each MAVLink and persistence feature is completed.
namespace RGCSModules {
constexpr auto VehicleManager = "VehicleManager";
constexpr auto ParameterManager = "ParameterManager";
constexpr auto CalibrationManager = "CalibrationManager";
constexpr auto FailsafeManager = "FailsafeManager";
constexpr auto DiagnosticManager = "DiagnosticManager";
constexpr auto VideoManager = "VideoManager";
constexpr auto MapProviderManager = "MapProviderManager";
constexpr auto TelemetryLogger = "TelemetryLogger";
constexpr auto NotificationManager = "NotificationManager";
}
