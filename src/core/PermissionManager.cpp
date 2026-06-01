#include "PermissionManager.h"

#include "core/AuditLogger.h"

PermissionManager::PermissionManager(AuditLogger *audit, QObject *parent)
    : QObject(parent)
    , m_audit(audit)
{
}

void PermissionManager::initialize()
{
    seedDefaults();
}

void PermissionManager::seedDefaults()
{
    const QSet<QString> all {
        "screen.home", "screen.fly", "screen.plan", "screen.setup", "screen.settings",
        "command.arm", "command.disarm", "command.takeoff", "command.land", "command.rtl",
        "command.pause", "command.startMission", "mission.edit", "mission.upload",
        "parameters.read", "parameters.write", "safety.write", "calibration.run",
        "diagnostics.view", "settings.write", "roles.configure"
    };
    m_permissions["Admin"] = all;
    m_permissions["Test Pilot"] = {
        "screen.home", "screen.fly", "screen.plan", "screen.setup",
        "command.arm", "command.disarm", "command.takeoff", "command.land", "command.rtl",
        "command.pause", "command.startMission", "mission.edit", "mission.upload",
        "parameters.read", "calibration.run", "diagnostics.view"
    };
    m_permissions["User"] = { "screen.home", "screen.fly" };
}

bool PermissionManager::can(const QString &role, const QString &permission) const
{
    return m_permissions.value(role).contains(permission);
}

QStringList PermissionManager::visibleScreens(const QString &role) const
{
    QStringList screens;
    const QList<QPair<QString, QString>> known {
        {"Home", "screen.home"}, {"Fly", "screen.fly"}, {"Plan", "screen.plan"},
        {"Setup", "screen.setup"}, {"Settings", "screen.settings"}
    };
    for (const auto &entry : known) {
        if (can(role, entry.second)) {
            screens << entry.first;
        }
    }
    return screens;
}

QStringList PermissionManager::permissionsForRole(const QString &role) const
{
    return QStringList(m_permissions.value(role).values());
}

void PermissionManager::setRolePermission(const QString &adminUser, const QString &role, const QString &permission, bool enabled)
{
    if (role == "Admin") {
        return;
    }

    if (enabled) {
        m_permissions[role].insert(permission);
    } else {
        m_permissions[role].remove(permission);
    }
    if (m_audit) {
        m_audit->record(adminUser, "role_permission_change", QString("%1 %2=%3").arg(role, permission, enabled ? "true" : "false"));
    }
    emit permissionsChanged();
}
