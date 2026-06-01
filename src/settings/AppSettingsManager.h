#pragma once

#include <QObject>
#include <QSettings>

class AppSettingsManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mapProvider READ mapProvider WRITE setMapProvider NOTIFY settingsChanged)
    Q_PROPERTY(QString coordinateType READ coordinateType WRITE setCoordinateType NOTIFY settingsChanged)
    Q_PROPERTY(bool telemetryLogging READ telemetryLogging WRITE setTelemetryLogging NOTIFY settingsChanged)
    Q_PROPERTY(bool outdoorMode READ outdoorMode WRITE setOutdoorMode NOTIFY settingsChanged)
    Q_PROPERTY(QString videoType READ videoType WRITE setVideoType NOTIFY settingsChanged)
    Q_PROPERTY(QString videoUrl READ videoUrl WRITE setVideoUrl NOTIFY settingsChanged)

public:
    explicit AppSettingsManager(QObject *parent = nullptr);

    void initialize();
    Q_INVOKABLE void save();

    QString mapProvider() const;
    void setMapProvider(const QString &value);
    QString coordinateType() const;
    void setCoordinateType(const QString &value);
    bool telemetryLogging() const;
    void setTelemetryLogging(bool value);
    bool outdoorMode() const;
    void setOutdoorMode(bool value);
    QString videoType() const;
    void setVideoType(const QString &value);
    QString videoUrl() const;
    void setVideoUrl(const QString &value);

signals:
    void settingsChanged();

private:
    QSettings m_settings;
    QString m_mapProvider = "OpenStreetMap";
    QString m_coordinateType = "Degree Decimal";
    bool m_telemetryLogging = true;
    bool m_outdoorMode = false;
    QString m_videoType = "RTSP";
    QString m_videoUrl;
};
