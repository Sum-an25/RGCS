#pragma once

#include <QHostAddress>
#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QUdpSocket>

class AuditLogger;

class MavlinkConnectionManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectionChanged)
    Q_PROPERTY(QString linkType READ linkType WRITE setLinkType NOTIFY linkSettingsChanged)
    Q_PROPERTY(QString endpoint READ endpoint WRITE setEndpoint NOTIFY linkSettingsChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY linkSettingsChanged)
    Q_PROPERTY(QString status READ status NOTIFY connectionChanged)

public:
    explicit MavlinkConnectionManager(AuditLogger *audit, QObject *parent = nullptr);

    void initialize();
    Q_INVOKABLE void connectLink();
    Q_INVOKABLE void disconnectLink();
    Q_INVOKABLE bool sendCommandLong(const QString &command, double value = 0.0);

    bool connected() const;
    QString linkType() const;
    void setLinkType(const QString &linkType);
    QString endpoint() const;
    void setEndpoint(const QString &endpoint);
    int port() const;
    void setPort(int port);
    QString status() const;

signals:
    void connectionChanged();
    void linkSettingsChanged();
    void heartbeatReceived();
    void commandAckReceived(QString command, QString result);
    void rawMessageReceived(int messageId, QByteArray payload);

private:
    void readPendingDatagrams();
    void readPendingTcpBytes();
    void parseMavlinkBytes(const QByteArray &bytes, const QHostAddress &sender, quint16 senderPort);
    void parseMavlinkFrame(const QByteArray &frame, const QHostAddress &sender, quint16 senderPort);
    void updateHeartbeatState();
    void sendGroundStationHeartbeat();
    QByteArray buildCommandLongFrame(quint16 command, const QList<float> &params);
    QByteArray buildHeartbeatFrame();

    AuditLogger *m_audit;
    QUdpSocket m_udpSocket;
    QTcpSocket m_tcpSocket;
    QByteArray m_tcpBuffer;
    bool m_connected = false;
    bool m_listening = false;
    QString m_linkType = "UDP";
    QString m_endpoint = "127.0.0.1";
    int m_port = 14550;
    QString m_status = "Disconnected";
    QTimer m_heartbeatTimer;
    QHostAddress m_lastSender;
    quint16 m_lastSenderPort = 0;
    quint8 m_targetSystem = 1;
    quint8 m_targetComponent = 1;
    quint8 m_sequence = 0;
    qint64 m_lastHeartbeatMs = 0;
    qint64 m_lastGcsHeartbeatMs = 0;
};
