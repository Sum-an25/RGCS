#include "CoordinateConverter.h"

#include <QtMath>

CoordinateConverter::CoordinateConverter(QObject *parent)
    : QObject(parent)
{
}

QString CoordinateConverter::decimalDegrees(double latitude, double longitude) const
{
    return QString("%1, %2").arg(latitude, 0, 'f', 7).arg(longitude, 0, 'f', 7);
}

QString CoordinateConverter::degreeMinuteSecond(double latitude, double longitude) const
{
    auto format = [](double value, const QString &positive, const QString &negative) {
        const QString hemi = value >= 0 ? positive : negative;
        const double absValue = qAbs(value);
        const int degrees = static_cast<int>(absValue);
        const double minutesFull = (absValue - degrees) * 60.0;
        const int minutes = static_cast<int>(minutesFull);
        const double seconds = (minutesFull - minutes) * 60.0;
        return QString("%1 deg %2' %3\" %4").arg(degrees).arg(minutes).arg(seconds, 0, 'f', 2).arg(hemi);
    };
    return format(latitude, "N", "S") + ", " + format(longitude, "E", "W");
}
