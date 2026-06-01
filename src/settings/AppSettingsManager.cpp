#include "AppSettingsManager.h"

AppSettingsManager::AppSettingsManager(QObject *parent)
    : QObject(parent)
{
}

void AppSettingsManager::initialize()
{
    m_mapProvider = m_settings.value("mapProvider", m_mapProvider).toString();
    m_coordinateType = m_settings.value("coordinateType", m_coordinateType).toString();
    m_telemetryLogging = m_settings.value("telemetryLogging", m_telemetryLogging).toBool();
    m_outdoorMode = m_settings.value("outdoorMode", m_outdoorMode).toBool();
    m_videoType = m_settings.value("videoType", m_videoType).toString();
    m_videoUrl = m_settings.value("videoUrl", m_videoUrl).toString();
}

void AppSettingsManager::save()
{
    m_settings.setValue("mapProvider", m_mapProvider);
    m_settings.setValue("coordinateType", m_coordinateType);
    m_settings.setValue("telemetryLogging", m_telemetryLogging);
    m_settings.setValue("outdoorMode", m_outdoorMode);
    m_settings.setValue("videoType", m_videoType);
    m_settings.setValue("videoUrl", m_videoUrl);
    m_settings.sync();
}

QString AppSettingsManager::mapProvider() const { return m_mapProvider; }
QString AppSettingsManager::coordinateType() const { return m_coordinateType; }
bool AppSettingsManager::telemetryLogging() const { return m_telemetryLogging; }
bool AppSettingsManager::outdoorMode() const { return m_outdoorMode; }
QString AppSettingsManager::videoType() const { return m_videoType; }
QString AppSettingsManager::videoUrl() const { return m_videoUrl; }

void AppSettingsManager::setMapProvider(const QString &value) { if (m_mapProvider != value) { m_mapProvider = value; emit settingsChanged(); } }
void AppSettingsManager::setCoordinateType(const QString &value) { if (m_coordinateType != value) { m_coordinateType = value; emit settingsChanged(); } }
void AppSettingsManager::setTelemetryLogging(bool value) { if (m_telemetryLogging != value) { m_telemetryLogging = value; emit settingsChanged(); } }
void AppSettingsManager::setOutdoorMode(bool value) { if (m_outdoorMode != value) { m_outdoorMode = value; emit settingsChanged(); } }
void AppSettingsManager::setVideoType(const QString &value) { if (m_videoType != value) { m_videoType = value; emit settingsChanged(); } }
void AppSettingsManager::setVideoUrl(const QString &value) { if (m_videoUrl != value) { m_videoUrl = value; emit settingsChanged(); } }
