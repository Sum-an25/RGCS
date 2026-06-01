#pragma once

#include <QObject>

#include "core/AuditLogger.h"
#include "core/AuthManager.h"
#include "core/PermissionManager.h"
#include "mavlink/CommandManager.h"
#include "mavlink/MavlinkConnectionManager.h"
#include "mavlink/TelemetryManager.h"
#include "mission/MissionManager.h"
#include "settings/AppSettingsManager.h"
#include "util/CoordinateConverter.h"

class AppController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AuthManager *auth READ auth CONSTANT)
    Q_PROPERTY(PermissionManager *permissions READ permissions CONSTANT)
    Q_PROPERTY(AppSettingsManager *settings READ settings CONSTANT)
    Q_PROPERTY(MavlinkConnectionManager *connection READ connection CONSTANT)
    Q_PROPERTY(TelemetryManager *telemetry READ telemetry CONSTANT)
    Q_PROPERTY(CommandManager *commands READ commands CONSTANT)
    Q_PROPERTY(MissionManager *missions READ missions CONSTANT)
    Q_PROPERTY(AuditLogger *audit READ audit CONSTANT)
    Q_PROPERTY(CoordinateConverter *coordinates READ coordinates CONSTANT)

public:
    explicit AppController(QObject *parent = nullptr);

    Q_INVOKABLE void initialize();

    AuthManager *auth();
    PermissionManager *permissions();
    AppSettingsManager *settings();
    MavlinkConnectionManager *connection();
    TelemetryManager *telemetry();
    CommandManager *commands();
    MissionManager *missions();
    AuditLogger *audit();
    CoordinateConverter *coordinates();

private:
    AuditLogger m_audit;
    PermissionManager m_permissions;
    AuthManager m_auth;
    AppSettingsManager m_settings;
    MavlinkConnectionManager m_connection;
    TelemetryManager m_telemetry;
    CommandManager m_commands;
    MissionManager m_missions;
    CoordinateConverter m_coordinates;
};
