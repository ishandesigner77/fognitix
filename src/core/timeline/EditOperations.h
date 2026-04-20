#pragma once

#include <optional>

#include <QString>

namespace Fognitix::Timeline {
class Timeline;
struct TimelineClip;
} // namespace Fognitix::Timeline

namespace Fognitix::Timeline {

class EditOperations {
public:
    static bool cutClipAtTime(Timeline& timeline, const QString& clipId, double timeOnTimeline);
    static bool rippleDeleteRange(Timeline& timeline, const QString& trackId, double start, double end);
};

} // namespace Fognitix::Timeline
