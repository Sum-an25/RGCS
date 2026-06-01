#pragma once

#include <QObject>
#include <QHash>
#include <QSet>
#include <QStringList>

class AuditLogger;

class PermissionManager final : public QObject
{
    Q_OBJECT

public:
    explicit PermissionManager(AuditLogger *audit, QObject *parent = nullptr);

    void initialize();
    Q_INVOKABLE bool can(const QString &role, const QString &permission) const;
    Q_INVOKABLE QStringList visibleScreens(const QString &role) const;
    Q_INVOKABLE QStringList permissionsForRole(const QString &role) const;
    Q_INVOKABLE void setRolePermission(const QString &adminUser, const QString &role, const QString &permission, bool enabled);

signals:
    void permissionsChanged();

private:
    void seedDefaults();

    AuditLogger *m_audit;
    QHash<QString, QSet<QString>> m_permissions;
};
