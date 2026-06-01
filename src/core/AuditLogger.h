#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QStringList>

class AuditLogger final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList recentEvents READ recentEvents NOTIFY recentEventsChanged)

public:
    explicit AuditLogger(QObject *parent = nullptr);

    void initialize();
    Q_INVOKABLE void record(const QString &actor, const QString &action, const QString &details);
    QStringList recentEvents() const;

signals:
    void recentEventsChanged();

private:
    QSqlDatabase m_db;
    QStringList m_recentEvents;
};
