#include "AuthManager.h"

#include "core/AuditLogger.h"
#include "core/PermissionManager.h"

#include <QCryptographicHash>
#include <QDir>
#include <QRandomGenerator>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVariant>

static QString authDbPath()
{
    const QString root = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(root);
    return root + "/rgcs.sqlite";
}

AuthManager::AuthManager(AuditLogger *audit, PermissionManager *permissions, QObject *parent)
    : QObject(parent)
    , m_audit(audit)
    , m_permissions(permissions)
{
}

void AuthManager::initialize()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE", "auth");
    m_db.setDatabaseName(authDbPath());
    if (!m_db.open()) {
        setError("Unable to open secure user store.");
        return;
    }

    QSqlQuery query(m_db);
    query.exec("CREATE TABLE IF NOT EXISTS users ("
               "username TEXT PRIMARY KEY,"
               "role TEXT NOT NULL,"
               "salt BLOB NOT NULL,"
               "password_hash BLOB NOT NULL,"
               "created_at TEXT NOT NULL)");
    seedAdmin();
}

void AuthManager::seedAdmin()
{
    QSqlQuery count(m_db);
    count.exec("SELECT COUNT(*) FROM users");
    if (count.next() && count.value(0).toInt() > 0) {
        return;
    }
    createUser("admin", "ChangeMe123!", "Admin");
}

QByteArray AuthManager::hashPassword(const QString &password, const QByteArray &salt) const
{
    QByteArray material = salt + password.toUtf8();
    for (int i = 0; i < 120000; ++i) {
        material = QCryptographicHash::hash(material, QCryptographicHash::Sha256);
    }
    return material;
}

bool AuthManager::createUser(const QString &username, const QString &password, const QString &role)
{
    if (username.trimmed().isEmpty() || password.size() < 10) {
        setError("Username is required and password must be at least 10 characters.");
        return false;
    }

    QSqlQuery count(m_db);
    count.exec("SELECT COUNT(*) FROM users");
    const bool firstUser = count.next() && count.value(0).toInt() == 0;
    if (!firstUser && (!m_loggedIn || !m_permissions->can(m_role, "roles.configure"))) {
        setError("Current role cannot create users.");
        return false;
    }

    QByteArray salt(24, Qt::Uninitialized);
    for (auto &byte : salt) {
        byte = static_cast<char>(QRandomGenerator::global()->bounded(256));
    }

    QSqlQuery query(m_db);
    query.prepare("INSERT OR REPLACE INTO users (username, role, salt, password_hash, created_at) VALUES (?, ?, ?, ?, datetime('now'))");
    query.addBindValue(username.trimmed());
    query.addBindValue(role);
    query.addBindValue(salt);
    query.addBindValue(hashPassword(password, salt));
    const bool ok = query.exec();
    if (ok && m_audit) {
        m_audit->record(m_username.isEmpty() ? "system" : m_username, "user_upsert", username + ":" + role);
    }
    return ok;
}

bool AuthManager::login(const QString &username, const QString &password)
{
    QSqlQuery query(m_db);
    query.prepare("SELECT role, salt, password_hash FROM users WHERE username = ?");
    query.addBindValue(username.trimmed());
    if (!query.exec() || !query.next()) {
        setError("Invalid username or password.");
        if (m_audit) {
            m_audit->record(username, "login_failed", "unknown_user");
        }
        return false;
    }

    const QByteArray salt = query.value(1).toByteArray();
    const QByteArray expected = query.value(2).toByteArray();
    if (hashPassword(password, salt) != expected) {
        setError("Invalid username or password.");
        if (m_audit) {
            m_audit->record(username, "login_failed", "bad_password");
        }
        return false;
    }

    m_loggedIn = true;
    m_username = username.trimmed();
    m_role = query.value(0).toString();
    setError(QString());
    if (m_audit) {
        m_audit->record(m_username, "login", m_role);
    }
    emit sessionChanged();
    return true;
}

void AuthManager::logout()
{
    if (m_loggedIn && m_audit) {
        m_audit->record(m_username, "logout", m_role);
    }
    m_loggedIn = false;
    m_username.clear();
    m_role.clear();
    emit sessionChanged();
}

bool AuthManager::loggedIn() const { return m_loggedIn; }
QString AuthManager::username() const { return m_username; }
QString AuthManager::role() const { return m_role; }
QString AuthManager::error() const { return m_error; }

void AuthManager::setError(const QString &error)
{
    if (m_error == error) {
        return;
    }
    m_error = error;
    emit errorChanged();
}
