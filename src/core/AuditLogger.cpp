#include "AuditLogger.h"

#include <QDateTime>
#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>

static QString dataPath()
{
    const QString root = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(root);
    return root + "/rgcs.sqlite";
}

AuditLogger::AuditLogger(QObject *parent)
    : QObject(parent)
{
}

void AuditLogger::initialize()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE", "audit");
    m_db.setDatabaseName(dataPath());
    if (!m_db.open()) {
        qWarning("Unable to open audit database");
        return;
    }

    QSqlQuery query(m_db);
    query.exec("CREATE TABLE IF NOT EXISTS audit_log ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
               "created_at TEXT NOT NULL,"
               "actor TEXT NOT NULL,"
               "action TEXT NOT NULL,"
               "details TEXT NOT NULL)");
}

void AuditLogger::record(const QString &actor, const QString &action, const QString &details)
{
    const QString line = QString("%1 | %2 | %3 | %4")
                             .arg(QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs), actor, action, details);
    m_recentEvents.prepend(line);
    while (m_recentEvents.size() > 100) {
        m_recentEvents.removeLast();
    }

    if (m_db.isOpen()) {
        QSqlQuery query(m_db);
        query.prepare("INSERT INTO audit_log (created_at, actor, action, details) VALUES (?, ?, ?, ?)");
        query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs));
        query.addBindValue(actor);
        query.addBindValue(action);
        query.addBindValue(details);
        query.exec();
    }

    emit recentEventsChanged();
}

QStringList AuditLogger::recentEvents() const
{
    return m_recentEvents;
}
