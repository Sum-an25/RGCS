#include "TelemetryManager.h"

#include "mavlink/MavlinkConnectionManager.h"

#include <QtMath>

TelemetryManager::TelemetryManager(MavlinkConnectionManager *connection, QObject *parent)
    : QObject(parent)
    , m_connection(connection)
{
    m_uiTimer.setInterval(75);
    connect(&m_uiTimer, &QTimer::timeout, this, &TelemetryManager::tickDemoTelemetry);
}

void TelemetryManager::initialize()
{
    m_uiTimer.start();
}

void TelemetryManager::tickDemoTelemetry()
{
    if (!m_connection->connected()) {
        m_gpsSatellites = 0;
        m_rcSignal = 0;
        emit telemetryChanged();
        return;
    }

    ++m_ticks;
    m_gpsSatellites = 14;
    m_rcSignal = 91;
    m_batteryPercent = qMax(8.0, 100.0 - m_ticks * 0.015);
    m_batteryVoltage = 12.6 + (m_batteryPercent / 100.0) * 4.2;
    m_altitude = 42.0 + qSin(m_ticks / 30.0) * 3.0;
    m_horizontalSpeed = 7.5 + qSin(m_ticks / 16.0);
    m_verticalSpeed = qCos(m_ticks / 24.0) * 0.4;
    m_distanceFromHome += 0.08;
    m_travelledDistance += m_horizontalSpeed * 0.075;
    m_latitude += 0.000001 * qSin(m_ticks / 20.0);
    m_longitude += 0.000001 * qCos(m_ticks / 18.0);
    emit telemetryChanged();
}

QString TelemetryManager::flightMode() const { return m_connection->connected() ? "LOITER" : "--"; }
QString TelemetryManager::armStatus() const { return m_connection->connected() ? "DISARMED" : "--"; }
double TelemetryManager::batteryPercent() const { return m_batteryPercent; }
double TelemetryManager::batteryVoltage() const { return m_batteryVoltage; }
int TelemetryManager::gpsSatellites() const { return m_gpsSatellites; }
QString TelemetryManager::gpsFixType() const { return m_connection->connected() ? "3D Fix" : "No Fix"; }
double TelemetryManager::verticalSpeed() const { return m_verticalSpeed; }
double TelemetryManager::horizontalSpeed() const { return m_horizontalSpeed; }
double TelemetryManager::distanceFromHome() const { return m_distanceFromHome; }
double TelemetryManager::altitude() const { return m_altitude; }
double TelemetryManager::travelledDistance() const { return m_travelledDistance; }
QString TelemetryManager::telemetryLink() const { return m_connection->connected() ? "Healthy" : "Offline"; }
int TelemetryManager::rcSignal() const { return m_rcSignal; }
QString TelemetryManager::timeInAir() const { return m_connection->connected() ? QString("%1:%2").arg(m_ticks / 800, 2, 10, QChar('0')).arg((m_ticks / 13) % 60, 2, 10, QChar('0')) : "00:00"; }
double TelemetryManager::latitude() const { return m_latitude; }
double TelemetryManager::longitude() const { return m_longitude; }
