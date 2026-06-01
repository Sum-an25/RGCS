#pragma once

#include <QObject>
#include <QSqlDatabase>

class AuditLogger;
class PermissionManager;

class AuthManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY sessionChanged)
    Q_PROPERTY(QString username READ username NOTIFY sessionChanged)
    Q_PROPERTY(QString role READ role NOTIFY sessionChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit AuthManager(AuditLogger *audit, PermissionManager *permissions, QObject *parent = nullptr);

    void initialize();
    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool createUser(const QString &username, const QString &password, const QString &role);

    bool loggedIn() const;
    QString username() const;
    QString role() const;
    QString error() const;

signals:
    void sessionChanged();
    void errorChanged();

private:
    QByteArray hashPassword(const QString &password, const QByteArray &salt) const;
    void setError(const QString &error);
    void seedAdmin();

    AuditLogger *m_audit;
    PermissionManager *m_permissions;
    QSqlDatabase m_db;
    bool m_loggedIn = false;
    QString m_username;
    QString m_role;
    QString m_error;
};
