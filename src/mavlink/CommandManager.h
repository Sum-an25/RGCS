#pragma once

#include <QObject>

class AuditLogger;
class AuthManager;
class MavlinkConnectionManager;
class PermissionManager;

class CommandManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastResult READ lastResult NOTIFY commandResultChanged)

public:
    explicit CommandManager(AuthManager *auth, PermissionManager *permissions, MavlinkConnectionManager *connection, AuditLogger *audit, QObject *parent = nullptr);

    Q_INVOKABLE bool sendCriticalCommand(const QString &command, double value = 0.0);
    Q_INVOKABLE bool canRun(const QString &command) const;
    QString lastResult() const;

signals:
    void commandResultChanged();

private:
    QString permissionForCommand(const QString &command) const;
    void setResult(const QString &result);

    AuthManager *m_auth;
    PermissionManager *m_permissions;
    MavlinkConnectionManager *m_connection;
    AuditLogger *m_audit;
    QString m_lastResult = "Idle";
};
