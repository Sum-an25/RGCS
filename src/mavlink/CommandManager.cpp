#include "CommandManager.h"

#include "core/AuditLogger.h"
#include "core/AuthManager.h"
#include "core/PermissionManager.h"
#include "mavlink/MavlinkConnectionManager.h"

CommandManager::CommandManager(AuthManager *auth, PermissionManager *permissions, MavlinkConnectionManager *connection, AuditLogger *audit, QObject *parent)
    : QObject(parent)
    , m_auth(auth)
    , m_permissions(permissions)
    , m_connection(connection)
    , m_audit(audit)
{
}

bool CommandManager::canRun(const QString &command) const
{
    return m_connection->connected() && m_auth->loggedIn() && m_permissions->can(m_auth->role(), permissionForCommand(command));
}

bool CommandManager::sendCriticalCommand(const QString &command, double value)
{
    if (!canRun(command)) {
        setResult("Rejected: permission, connection, or state check failed");
        if (m_audit) {
            m_audit->record(m_auth->username(), "critical_command_rejected", command);
        }
        return false;
    }

    if (!m_connection->sendCommandLong(command, value)) {
        setResult(QString("%1 failed to send").arg(command));
        if (m_audit) {
            m_audit->record(m_auth->username(), "critical_command_failed", command);
        }
        return false;
    }

    setResult(QString("%1 sent").arg(command));
    if (m_audit) {
        m_audit->record(m_auth->username(), "critical_command", QString("%1 value=%2").arg(command).arg(value));
    }
    return true;
}

QString CommandManager::permissionForCommand(const QString &command) const
{
    const QString key = command.trimmed().toLower();
    if (key == "start mission") {
        return "command.startMission";
    }
    return "command." + key;
}

QString CommandManager::lastResult() const { return m_lastResult; }

void CommandManager::setResult(const QString &result)
{
    if (m_lastResult == result) {
        return;
    }
    m_lastResult = result;
    emit commandResultChanged();
}
