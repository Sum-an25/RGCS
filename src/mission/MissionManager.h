#pragma once

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QHash>
#include <QTimer>
#include <QVariant>

class AuditLogger;
class AuthManager;
class MavlinkConnectionManager;
class PermissionManager;

struct MissionItem {
    int sequence = 0;
    QString command;
    double latitude = 0.0;
    double longitude = 0.0;
    double altitude = 0.0;
    double holdTime = 0.0;
};

class MissionManager final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool editing READ editing NOTIFY missionChanged)
    Q_PROPERTY(double missionAltitude READ missionAltitude NOTIFY missionChanged)
    Q_PROPERTY(QVariantList missionPath READ missionPath NOTIFY missionChanged)
    Q_PROPERTY(QString uploadStatus READ uploadStatus NOTIFY uploadStatusChanged)
    Q_PROPERTY(int uploadProgress READ uploadProgress NOTIFY uploadStatusChanged)

public:
    enum Roles { SequenceRole = Qt::UserRole + 1, CommandRole, LatitudeRole, LongitudeRole, AltitudeRole, HoldTimeRole };

    explicit MissionManager(AuthManager *auth, PermissionManager *permissions, MavlinkConnectionManager *connection, AuditLogger *audit, QObject *parent = nullptr);

    void initialize();
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void newMission(double altitude);
    Q_INVOKABLE void addWaypoint(double latitude, double longitude);
    Q_INVOKABLE void addLandAtLastWaypoint();
    Q_INVOKABLE void addLandAtHome(double latitude, double longitude);
    Q_INVOKABLE void clearMission();
    Q_INVOKABLE void uploadMission();
    Q_INVOKABLE void downloadMission();

    bool editing() const;
    double missionAltitude() const;
    QVariantList missionPath() const;
    QString uploadStatus() const;
    int uploadProgress() const;

signals:
    void missionChanged();
    void uploadStatusChanged();

private:
    void addItem(const QString &command, double latitude, double longitude, double altitude);

    AuthManager *m_auth;
    PermissionManager *m_permissions;
    MavlinkConnectionManager *m_connection;
    AuditLogger *m_audit;
    QList<MissionItem> m_items;
    bool m_editing = false;
    double m_missionAltitude = 50.0;
    QString m_uploadStatus = "Idle";
    int m_uploadProgress = 0;
};
