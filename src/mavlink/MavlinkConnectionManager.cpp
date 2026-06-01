#include "MavlinkConnectionManager.h"

#include "core/AuditLogger.h"

#include <QDateTime>
#include <QDataStream>
#include <QNetworkDatagram>
#include <QtEndian>

namespace {
constexpr quint8 Mavlink2Magic = 0xFD;
constexpr quint16 MavCmdComponentArmDisarm = 400;
constexpr quint16 MavCmdNavTakeoff = 22;
constexpr quint16 MavCmdNavLand = 21;
constexpr quint16 MavCmdNavReturnToLaunch = 20;
constexpr quint16 MavCmdMissionStart = 300;
constexpr quint16 MavCmdDoPauseContinue = 193;
constexpr quint16 MavCmdDoSetMode = 176;
constexpr quint8 CommandLongCrcExtra = 152;
constexpr quint8 HeartbeatCrcExtra = 50;

void crcAccumulate(quint8 data, quint16 &crc)
{
    data ^= static_cast<quint8>(crc & 0xff);
    data ^= data << 4;
    crc = (crc >> 8) ^ (static_cast<quint16>(data) << 8) ^ (static_cast<quint16>(data) << 3) ^ (static_cast<quint16>(data) >> 4);
}

quint16 mavlinkChecksum(const QByteArray &bytes, quint8 crcExtra)
{
    quint16 crc = 0xffff;
    for (const char byte : bytes) {
        crcAccumulate(static_cast<quint8>(byte), crc);
    }
    crcAccumulate(crcExtra, crc);
    return crc;
}

void appendUInt16(QByteArray &payload, quint16 value)
{
    const quint16 le = qToLittleEndian(value);
    payload.append(reinterpret_cast<const char *>(&le), sizeof(le));
}

void appendFloat(QByteArray &payload, float value)
{
    quint32 raw = 0;
    static_assert(sizeof(raw) == sizeof(value));
    memcpy(&raw, &value, sizeof(value));
    raw = qToLittleEndian(raw);
    payload.append(reinterpret_cast<const char *>(&raw), sizeof(raw));
}

quint16 commandForName(const QString &command)
{
    const QString key = command.trimmed().toLower();
    if (key == "arm" || key == "disarm") {
        return MavCmdComponentArmDisarm;
    }
    if (key == "takeoff") {
        return MavCmdNavTakeoff;
    }
    if (key == "land") {
        return MavCmdNavLand;
    }
    if (key == "rtl") {
        return MavCmdNavReturnToLaunch;
    }
    if (key == "start mission") {
        return MavCmdMissionStart;
    }
    if (key == "pause") {
        return MavCmdDoPauseContinue;
    }
    return MavCmdDoSetMode;
}
}

MavlinkConnectionManager::MavlinkConnectionManager(AuditLogger *audit, QObject *parent)
    : QObject(parent)
    , m_audit(audit)
{
    m_heartbeatTimer.setInterval(500);
    connect(&m_heartbeatTimer, &QTimer::timeout, this, &MavlinkConnectionManager::updateHeartbeatState);
    connect(&m_udpSocket, &QUdpSocket::readyRead, this, &MavlinkConnectionManager::readPendingDatagrams);
    connect(&m_tcpSocket, &QTcpSocket::readyRead, this, &MavlinkConnectionManager::readPendingTcpBytes);
    connect(&m_tcpSocket, &QTcpSocket::connected, this, [this]() {
        if (!m_connected) {
            m_status = "Connected to SITL TCP, waiting for MAVLink heartbeat";
            emit connectionChanged();
        }
    });
}

void MavlinkConnectionManager::initialize()
{
}

void MavlinkConnectionManager::connectLink()
{
    if (m_listening) {
        return;
    }

    if (m_linkType != "UDP") {
        m_status = QString("%1 transport is not implemented yet").arg(m_linkType);
        emit connectionChanged();
        return;
    }

    const QHostAddress bindAddress = m_endpoint == "0.0.0.0" ? QHostAddress::AnyIPv4 : QHostAddress(m_endpoint);
    const bool bound = m_udpSocket.bind(bindAddress, static_cast<quint16>(m_port), QUdpSocket::DefaultForPlatform);
    if (!bound) {
        m_status = "UDP bind failed: " + m_udpSocket.errorString();
        emit connectionChanged();
        return;
    }

    m_listening = true;
    m_connected = false;
    m_lastHeartbeatMs = 0;
    m_status = QString("Listening for MAVLink on UDP :%1").arg(m_port);
    m_heartbeatTimer.start();
    m_tcpBuffer.clear();
    m_tcpSocket.abort();
    m_tcpSocket.connectToHost(QHostAddress(m_endpoint), 5760);
    if (m_audit) {
        m_audit->record("system", "mavlink_connect", m_status);
    }
    emit connectionChanged();
}

void MavlinkConnectionManager::disconnectLink()
{
    m_connected = false;
    m_listening = false;
    m_status = "Disconnected";
    m_heartbeatTimer.stop();
    m_udpSocket.close();
    m_tcpSocket.abort();
    m_tcpBuffer.clear();
    if (m_audit) {
        m_audit->record("system", "mavlink_disconnect", "link closed");
    }
    emit connectionChanged();
}

bool MavlinkConnectionManager::connected() const { return m_connected; }
QString MavlinkConnectionManager::linkType() const { return m_linkType; }
QString MavlinkConnectionManager::endpoint() const { return m_endpoint; }
int MavlinkConnectionManager::port() const { return m_port; }
QString MavlinkConnectionManager::status() const { return m_status; }

bool MavlinkConnectionManager::sendCommandLong(const QString &command, double value)
{
    if (!m_listening || !m_connected) {
        return false;
    }

    QList<float> params {0, 0, 0, 0, 0, 0, 0};
    const QString key = command.trimmed().toLower();
    if (key == "arm") {
        params[0] = 1.0f;
    } else if (key == "disarm") {
        params[0] = 0.0f;
    } else if (key == "takeoff") {
        params[6] = static_cast<float>(value > 0.0 ? value : 30.0);
    } else if (key == "pause") {
        params[0] = 0.0f;
    } else if (key == "start mission") {
        params[0] = 0.0f;
        params[1] = 0.0f;
    }

    const QByteArray frame = buildCommandLongFrame(commandForName(command), params);
    if (m_tcpSocket.state() == QAbstractSocket::ConnectedState) {
        return m_tcpSocket.write(frame) == frame.size();
    }

    const QHostAddress targetAddress = m_lastSender.isNull() ? QHostAddress(m_endpoint) : m_lastSender;
    const quint16 targetPort = m_lastSenderPort == 0 ? static_cast<quint16>(m_port) : m_lastSenderPort;
    const qint64 written = m_udpSocket.writeDatagram(frame, targetAddress, targetPort);
    return written == frame.size();
}

void MavlinkConnectionManager::readPendingDatagrams()
{
    while (m_udpSocket.hasPendingDatagrams()) {
        const QNetworkDatagram datagram = m_udpSocket.receiveDatagram();
        parseMavlinkBytes(datagram.data(), datagram.senderAddress(), datagram.senderPort());
    }
}

void MavlinkConnectionManager::parseMavlinkBytes(const QByteArray &bytes, const QHostAddress &sender, quint16 senderPort)
{
    int offset = 0;
    while (offset < bytes.size()) {
        const int magicIndexFd = bytes.indexOf(static_cast<char>(Mavlink2Magic), offset);
        const int magicIndexFe = bytes.indexOf(static_cast<char>(0xFE), offset);
        int magicIndex = -1;
        if (magicIndexFd >= 0 && magicIndexFe >= 0) {
            magicIndex = qMin(magicIndexFd, magicIndexFe);
        } else {
            magicIndex = qMax(magicIndexFd, magicIndexFe);
        }

        if (magicIndex < 0 || magicIndex + 2 >= bytes.size()) {
            return;
        }

        const quint8 magic = static_cast<quint8>(bytes.at(magicIndex));
        const int payloadLength = static_cast<quint8>(bytes.at(magicIndex + 1));
        const int headerLength = magic == Mavlink2Magic ? 10 : 6;
        const int checksumLength = 2;
        const int signatureLength = magic == Mavlink2Magic && magicIndex + 3 < bytes.size() && (static_cast<quint8>(bytes.at(magicIndex + 2)) & 0x01) ? 13 : 0;
        const int frameLength = headerLength + payloadLength + checksumLength + signatureLength;

        if (magicIndex + frameLength > bytes.size()) {
            return;
        }

        parseMavlinkFrame(bytes.mid(magicIndex, frameLength), sender, senderPort);
        offset = magicIndex + frameLength;
    }
}

void MavlinkConnectionManager::readPendingTcpBytes()
{
    m_tcpBuffer.append(m_tcpSocket.readAll());

    int offset = 0;
    while (offset < m_tcpBuffer.size()) {
        const int magicIndexFd = m_tcpBuffer.indexOf(static_cast<char>(Mavlink2Magic), offset);
        const int magicIndexFe = m_tcpBuffer.indexOf(static_cast<char>(0xFE), offset);
        int magicIndex = -1;
        if (magicIndexFd >= 0 && magicIndexFe >= 0) {
            magicIndex = qMin(magicIndexFd, magicIndexFe);
        } else {
            magicIndex = qMax(magicIndexFd, magicIndexFe);
        }

        if (magicIndex < 0) {
            m_tcpBuffer.clear();
            return;
        }
        if (magicIndex + 2 >= m_tcpBuffer.size()) {
            if (magicIndex > 0) {
                m_tcpBuffer.remove(0, magicIndex);
            }
            return;
        }

        const quint8 magic = static_cast<quint8>(m_tcpBuffer.at(magicIndex));
        const int payloadLength = static_cast<quint8>(m_tcpBuffer.at(magicIndex + 1));
        const int headerLength = magic == Mavlink2Magic ? 10 : 6;
        const int checksumLength = 2;
        const int signatureLength = magic == Mavlink2Magic && magicIndex + 3 < m_tcpBuffer.size() && (static_cast<quint8>(m_tcpBuffer.at(magicIndex + 2)) & 0x01) ? 13 : 0;
        const int frameLength = headerLength + payloadLength + checksumLength + signatureLength;
        if (magicIndex + frameLength > m_tcpBuffer.size()) {
            if (magicIndex > 0) {
                m_tcpBuffer.remove(0, magicIndex);
            }
            return;
        }

        parseMavlinkFrame(m_tcpBuffer.mid(magicIndex, frameLength), QHostAddress(m_endpoint), 5760);
        offset = magicIndex + frameLength;
    }

    if (offset > 0) {
        m_tcpBuffer.remove(0, offset);
    }
}

void MavlinkConnectionManager::parseMavlinkFrame(const QByteArray &frame, const QHostAddress &sender, quint16 senderPort)
{
    if (frame.size() < 8) {
        return;
    }

    const auto magic = static_cast<quint8>(frame.at(0));
    int payloadLength = 0;
    int payloadOffset = 0;
    int messageId = -1;
    quint8 sysid = 0;
    quint8 compid = 0;

    if (magic == 0xFE) {
        payloadLength = static_cast<quint8>(frame.at(1));
        if (frame.size() < 6 + payloadLength + 2) {
            return;
        }
        sysid = static_cast<quint8>(frame.at(3));
        compid = static_cast<quint8>(frame.at(4));
        messageId = static_cast<quint8>(frame.at(5));
        payloadOffset = 6;
    } else if (magic == Mavlink2Magic) {
        payloadLength = static_cast<quint8>(frame.at(1));
        if (frame.size() < 10 + payloadLength + 2) {
            return;
        }
        sysid = static_cast<quint8>(frame.at(5));
        compid = static_cast<quint8>(frame.at(6));
        messageId = static_cast<quint8>(frame.at(7))
            | (static_cast<quint8>(frame.at(8)) << 8)
            | (static_cast<quint8>(frame.at(9)) << 16);
        payloadOffset = 10;
    } else {
        return;
    }

    const QByteArray payload = frame.mid(payloadOffset, payloadLength);
    emit rawMessageReceived(messageId, payload);

    if (messageId == 0) {
        if (sysid == 255 && compid == 190) {
            return;
        }
        m_lastSender = sender;
        m_lastSenderPort = senderPort;
        m_targetSystem = sysid;
        m_targetComponent = compid;
        m_lastHeartbeatMs = QDateTime::currentMSecsSinceEpoch();
        if (!m_connected) {
            m_connected = true;
            m_status = QString("MAVLink heartbeat from %1:%2 system %3 component %4")
                           .arg(sender.toString())
                           .arg(senderPort)
                           .arg(m_targetSystem)
                           .arg(m_targetComponent);
            emit connectionChanged();
        }
        emit heartbeatReceived();
    } else if (messageId == 77 && payload.size() >= 3) {
        const quint16 command = qFromLittleEndian<quint16>(reinterpret_cast<const uchar *>(payload.constData()));
        const quint8 result = static_cast<quint8>(payload.at(2));
        emit commandAckReceived(QString::number(command), result == 0 ? "Accepted" : QString("Result %1").arg(result));
    }
}

void MavlinkConnectionManager::updateHeartbeatState()
{
    if (!m_listening) {
        return;
    }
    sendGroundStationHeartbeat();
    if (m_lastHeartbeatMs == 0) {
        return;
    }
    const bool healthy = QDateTime::currentMSecsSinceEpoch() - m_lastHeartbeatMs < 3000;
    if (m_connected != healthy) {
        m_connected = healthy;
        m_status = healthy ? m_status : QString("MAVLink heartbeat timeout on UDP :%1").arg(m_port);
        emit connectionChanged();
    }
}

void MavlinkConnectionManager::sendGroundStationHeartbeat()
{
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    if (now - m_lastGcsHeartbeatMs < 1000) {
        return;
    }
    m_lastGcsHeartbeatMs = now;

    const QByteArray frame = buildHeartbeatFrame();
    if (m_tcpSocket.state() == QAbstractSocket::ConnectedState) {
        m_tcpSocket.write(frame);
    }
}

QByteArray MavlinkConnectionManager::buildHeartbeatFrame()
{
    QByteArray payload;
    payload.reserve(9);
    payload.append(char(0));
    payload.append(char(0));
    payload.append(char(0));
    payload.append(char(0));
    payload.append(char(6));
    payload.append(char(8));
    payload.append(char(0));
    payload.append(char(4));
    payload.append(char(3));

    QByteArray frame;
    frame.reserve(21);
    frame.append(static_cast<char>(Mavlink2Magic));
    frame.append(static_cast<char>(payload.size()));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(m_sequence++));
    frame.append(static_cast<char>(255));
    frame.append(static_cast<char>(190));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(0));
    frame.append(payload);

    const quint16 crc = mavlinkChecksum(frame.mid(1), HeartbeatCrcExtra);
    appendUInt16(frame, crc);
    return frame;
}

QByteArray MavlinkConnectionManager::buildCommandLongFrame(quint16 command, const QList<float> &params)
{
    QByteArray payload;
    payload.reserve(33);
    for (int i = 0; i < 7; ++i) {
        appendFloat(payload, i < params.size() ? params.at(i) : 0.0f);
    }
    appendUInt16(payload, command);
    payload.append(static_cast<char>(m_targetSystem));
    payload.append(static_cast<char>(m_targetComponent));
    payload.append(static_cast<char>(0));

    QByteArray frame;
    frame.reserve(45);
    frame.append(static_cast<char>(Mavlink2Magic));
    frame.append(static_cast<char>(payload.size()));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(m_sequence++));
    frame.append(static_cast<char>(255));
    frame.append(static_cast<char>(190));
    frame.append(static_cast<char>(76));
    frame.append(static_cast<char>(0));
    frame.append(static_cast<char>(0));
    frame.append(payload);

    const QByteArray crcInput = frame.mid(1);
    const quint16 crc = mavlinkChecksum(crcInput, CommandLongCrcExtra);
    appendUInt16(frame, crc);
    return frame;
}

void MavlinkConnectionManager::setLinkType(const QString &linkType)
{
    if (m_linkType == linkType) {
        return;
    }
    m_linkType = linkType;
    emit linkSettingsChanged();
}

void MavlinkConnectionManager::setEndpoint(const QString &endpoint)
{
    if (m_endpoint == endpoint) {
        return;
    }
    m_endpoint = endpoint;
    emit linkSettingsChanged();
}

void MavlinkConnectionManager::setPort(int port)
{
    if (m_port == port) {
        return;
    }
    m_port = port;
    emit linkSettingsChanged();
}
