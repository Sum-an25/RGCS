#pragma once

#include <QObject>
#include <QTimer>

class MavlinkConnectionManager;

class TelemetryManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString flightMode READ flightMode NOTIFY telemetryChanged)
    Q_PROPERTY(QString armStatus READ armStatus NOTIFY telemetryChanged)
    Q_PROPERTY(double batteryPercent READ batteryPercent NOTIFY telemetryChanged)
    Q_PROPERTY(double batteryVoltage READ batteryVoltage NOTIFY telemetryChanged)
    Q_PROPERTY(int gpsSatellites READ gpsSatellites NOTIFY telemetryChanged)
    Q_PROPERTY(QString gpsFixType READ gpsFixType NOTIFY telemetryChanged)
    Q_PROPERTY(double verticalSpeed READ verticalSpeed NOTIFY telemetryChanged)
    Q_PROPERTY(double horizontalSpeed READ horizontalSpeed NOTIFY telemetryChanged)
    Q_PROPERTY(double distanceFromHome READ distanceFromHome NOTIFY telemetryChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY telemetryChanged)
    Q_PROPERTY(double travelledDistance READ travelledDistance NOTIFY telemetryChanged)
    Q_PROPERTY(QString telemetryLink READ telemetryLink NOTIFY telemetryChanged)
    Q_PROPERTY(int rcSignal READ rcSignal NOTIFY telemetryChanged)
    Q_PROPERTY(QString timeInAir READ timeInAir NOTIFY telemetryChanged)
    Q_PROPERTY(double latitude READ latitude NOTIFY telemetryChanged)
    Q_PROPERTY(double longitude READ longitude NOTIFY telemetryChanged)

public:
    explicit TelemetryManager(MavlinkConnectionManager *connection, QObject *parent = nullptr);

    void initialize();
    QString flightMode() const;
    QString armStatus() const;
    double batteryPercent() const;
    double batteryVoltage() const;
    int gpsSatellites() const;
    QString gpsFixType() const;
    double verticalSpeed() const;
    double horizontalSpeed() const;
    double distanceFromHome() const;
    double altitude() const;
    double travelledDistance() const;
    QString telemetryLink() const;
    int rcSignal() const;
    QString timeInAir() const;
    double latitude() const;
    double longitude() const;

signals:
    void telemetryChanged();
    void notificationRaised(QString severity, QString message);

private:
    void tickDemoTelemetry();

    MavlinkConnectionManager *m_connection;
    QTimer m_uiTimer;
    int m_ticks = 0;
    double m_batteryPercent = 100.0;
    double m_batteryVoltage = 16.8;
    int m_gpsSatellites = 0;
    double m_verticalSpeed = 0.0;
    double m_horizontalSpeed = 0.0;
    double m_distanceFromHome = 0.0;
    double m_altitude = 0.0;
    double m_travelledDistance = 0.0;
    int m_rcSignal = 0;
    double m_latitude = 12.9716;
    double m_longitude = 77.5946;
};
