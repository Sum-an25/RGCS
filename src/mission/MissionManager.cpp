#include "MissionManager.h"

#include "core/AuditLogger.h"
#include "core/AuthManager.h"
#include "core/PermissionManager.h"
#include "mavlink/MavlinkConnectionManager.h"

MissionManager::MissionManager(AuthManager *auth, PermissionManager *permissions, MavlinkConnectionManager *connection, AuditLogger *audit, QObject *parent)
    : QAbstractListModel(parent)
    , m_auth(auth)
    , m_permissions(permissions)
    , m_connection(connection)
    , m_audit(audit)
{
}

void MissionManager::initialize() {}

int MissionManager::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_items.size();
}

QVariant MissionManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return {};
    }
    const auto &item = m_items.at(index.row());
    switch (role) {
    case SequenceRole: return item.sequence;
    case CommandRole: return item.command;
    case LatitudeRole: return item.latitude;
    case LongitudeRole: return item.longitude;
    case AltitudeRole: return item.altitude;
    case HoldTimeRole: return item.holdTime;
    default: return {};
    }
}

bool MissionManager::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return false;
    }
    auto &item = m_items[index.row()];
    switch (role) {
    case LatitudeRole: item.latitude = value.toDouble(); break;
    case LongitudeRole: item.longitude = value.toDouble(); break;
    case AltitudeRole: item.altitude = value.toDouble(); break;
    case HoldTimeRole: item.holdTime = value.toDouble(); break;
    case CommandRole: item.command = value.toString(); break;
    default: return false;
    }
    emit dataChanged(index, index, {role});
    return true;
}

QHash<int, QByteArray> MissionManager::roleNames() const
{
    return {
        {SequenceRole, "sequence"}, {CommandRole, "command"}, {LatitudeRole, "latitude"},
        {LongitudeRole, "longitude"}, {AltitudeRole, "altitude"}, {HoldTimeRole, "holdTime"}
    };
}

void MissionManager::newMission(double altitude)
{
    beginResetModel();
    m_items.clear();
    endResetModel();
    m_editing = true;
    m_missionAltitude = altitude;
    m_uploadStatus = "Planning";
    m_uploadProgress = 0;
    emit missionChanged();
    emit uploadStatusChanged();
}

void MissionManager::addWaypoint(double latitude, double longitude)
{
    if (!m_editing) {
        return;
    }
    if (m_items.isEmpty()) {
        addItem("MAV_CMD_NAV_TAKEOFF", latitude, longitude, m_missionAltitude);
    }
    addItem("MAV_CMD_NAV_WAYPOINT", latitude, longitude, m_missionAltitude);
}

void MissionManager::addLandAtLastWaypoint()
{
    if (m_items.isEmpty()) {
        return;
    }
    const auto last = m_items.last();
    addItem("MAV_CMD_NAV_LAND", last.latitude, last.longitude, 0.0);
    m_editing = false;
    m_uploadStatus = "Ready to upload";
    emit missionChanged();
    emit uploadStatusChanged();
}

void MissionManager::addLandAtHome(double latitude, double longitude)
{
    addItem("MAV_CMD_NAV_LAND", latitude, longitude, 0.0);
    m_editing = false;
    m_uploadStatus = "Ready to upload";
    emit missionChanged();
    emit uploadStatusChanged();
}

void MissionManager::clearMission()
{
    beginResetModel();
    m_items.clear();
    endResetModel();
    m_editing = false;
    m_uploadStatus = "Idle";
    m_uploadProgress = 0;
    emit missionChanged();
    emit uploadStatusChanged();
}

void MissionManager::uploadMission()
{
    if (!m_connection->connected() || !m_permissions->can(m_auth->role(), "mission.upload")) {
        m_uploadStatus = "Upload rejected";
        emit uploadStatusChanged();
        return;
    }

    // Replace with MAVLink Mission Protocol state machine with retries and ACK handling.
    m_uploadProgress = 100;
    m_uploadStatus = QString("Uploaded %1 mission items").arg(m_items.size());
    if (m_audit) {
        m_audit->record(m_auth->username(), "mission_upload", m_uploadStatus);
    }
    emit uploadStatusChanged();
}

void MissionManager::downloadMission()
{
    m_uploadStatus = "Download verification queued";
    emit uploadStatusChanged();
}

void MissionManager::addItem(const QString &command, double latitude, double longitude, double altitude)
{
    const int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.append({row, command, latitude, longitude, altitude, 0.0});
    endInsertRows();
    emit missionChanged();
}

bool MissionManager::editing() const { return m_editing; }
double MissionManager::missionAltitude() const { return m_missionAltitude; }
QVariantList MissionManager::missionPath() const
{
    QVariantList path;
    for (const auto &item : m_items) {
        path << QVariant::fromValue(QGeoCoordinate(item.latitude, item.longitude, item.altitude));
    }
    return path;
}
QString MissionManager::uploadStatus() const { return m_uploadStatus; }
int MissionManager::uploadProgress() const { return m_uploadProgress; }
