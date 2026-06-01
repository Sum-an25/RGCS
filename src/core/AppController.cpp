#include "AppController.h"

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_audit(this)
    , m_permissions(&m_audit, this)
    , m_auth(&m_audit, &m_permissions, this)
    , m_settings(this)
    , m_connection(&m_audit, this)
    , m_telemetry(&m_connection, this)
    , m_commands(&m_auth, &m_permissions, &m_connection, &m_audit, this)
    , m_missions(&m_auth, &m_permissions, &m_connection, &m_audit, this)
    , m_coordinates(this)
{
}

void AppController::initialize()
{
    m_audit.initialize();
    m_permissions.initialize();
    m_auth.initialize();
    m_settings.initialize();
    m_connection.initialize();
    m_telemetry.initialize();
    m_missions.initialize();
}

AuthManager *AppController::auth() { return &m_auth; }
PermissionManager *AppController::permissions() { return &m_permissions; }
AppSettingsManager *AppController::settings() { return &m_settings; }
MavlinkConnectionManager *AppController::connection() { return &m_connection; }
TelemetryManager *AppController::telemetry() { return &m_telemetry; }
CommandManager *AppController::commands() { return &m_commands; }
MissionManager *AppController::missions() { return &m_missions; }
AuditLogger *AppController::audit() { return &m_audit; }
CoordinateConverter *AppController::coordinates() { return &m_coordinates; }
