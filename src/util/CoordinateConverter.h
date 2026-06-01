#pragma once

#include <QObject>

class CoordinateConverter final : public QObject
{
    Q_OBJECT

public:
    explicit CoordinateConverter(QObject *parent = nullptr);

    Q_INVOKABLE QString decimalDegrees(double latitude, double longitude) const;
    Q_INVOKABLE QString degreeMinuteSecond(double latitude, double longitude) const;
};
