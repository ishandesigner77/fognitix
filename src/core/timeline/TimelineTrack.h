#pragma once

#include <vector>

#include <QString>

#include "TimelineClip.h"

namespace Fognitix::Timeline {

enum class TrackType : int { Video = 0, Audio = 1, Adjustment = 2, Text = 3 };

struct TimelineTrack {
    QString id;
    QString name;
    TrackType type = TrackType::Video;
    int sortIndex = 0;
    int heightPx = 52;
    QString labelColor;
    std::vector<TimelineClip> clips;
};

} // namespace Fognitix::Timeline
