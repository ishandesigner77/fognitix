#pragma once

#include <QString>

#include <QJsonArray>

namespace Fognitix::Timeline {

struct TimelineClip {
    QString id;
    QString trackId;
    QString mediaId;
    double startOnTimeline = 0.0;
    double duration = 1.0;
    double sourceInPoint = 0.0;
    double speed = 1.0;
    QJsonArray effectStack;
};

} // namespace Fognitix::Timeline
