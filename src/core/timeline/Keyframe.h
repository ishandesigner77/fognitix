#pragma once

#include <QString>

#include <QJsonObject>
#include <QJsonValue>

namespace Fognitix::Timeline {

struct Keyframe {
    double time = 0.0;
    QString parameterId;
    QJsonValue value;
    QString easing = QStringLiteral("linear");
};

} // namespace Fognitix::Timeline
