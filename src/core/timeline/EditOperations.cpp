#include "EditOperations.h"

#include "Timeline.h"

#include <QUuid>

#include <algorithm>

namespace Fognitix::Timeline {

bool EditOperations::cutClipAtTime(Timeline& timeline, const QString& clipId, double timeOnTimeline)
{
    auto clipOpt = timeline.findClip(clipId);
    if (!clipOpt.has_value()) {
        return false;
    }
    TimelineClip* clipPtr = clipOpt.value();
    const double rel = timeOnTimeline - clipPtr->startOnTimeline;
    if (rel <= 0.0 || rel >= clipPtr->duration) {
        return false;
    }

    for (auto& track : timeline.tracks()) {
        for (auto it = track.clips.begin(); it != track.clips.end(); ++it) {
            if (it->id != clipId) {
                continue;
            }
            TimelineClip tail = *it;
            tail.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
            tail.startOnTimeline = timeOnTimeline;
            tail.duration = it->duration - rel;
            tail.sourceInPoint = it->sourceInPoint + rel * it->speed;
            it->duration = rel;
            track.clips.insert(std::next(it), tail);
            return true;
        }
    }
    return false;
}

bool EditOperations::rippleDeleteRange(Timeline& timeline, const QString& trackId, double start, double end)
{
    if (end <= start) {
        return false;
    }
    const double delta = end - start;
    for (auto& track : timeline.tracks()) {
        if (track.id != trackId) {
            continue;
        }
        std::vector<TimelineClip> kept;
        kept.reserve(track.clips.size());
        for (const auto& c : track.clips) {
            const double cEnd = c.startOnTimeline + c.duration;
            if (cEnd <= start || c.startOnTimeline >= end) {
                TimelineClip nc = c;
                if (nc.startOnTimeline >= end) {
                    nc.startOnTimeline -= delta;
                }
                kept.push_back(nc);
                continue;
            }
            if (c.startOnTimeline < start && cEnd > end) {
                TimelineClip a = c;
                a.duration = start - a.startOnTimeline;
                TimelineClip b = c;
                b.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
                b.startOnTimeline = end;
                b.duration = cEnd - end;
                b.sourceInPoint = c.sourceInPoint + (end - c.startOnTimeline) * c.speed;
                kept.push_back(a);
                kept.push_back(b);
                continue;
            }
            if (c.startOnTimeline >= start && cEnd <= end) {
                continue;
            }
            if (c.startOnTimeline < start) {
                TimelineClip a = c;
                a.duration = start - a.startOnTimeline;
                kept.push_back(a);
                continue;
            }
            TimelineClip b = c;
            b.startOnTimeline = end;
            b.duration = cEnd - end;
            b.sourceInPoint = c.sourceInPoint + (end - c.startOnTimeline) * c.speed;
            kept.push_back(b);
        }
        track.clips = std::move(kept);
        return true;
    }
    return false;
}

} // namespace Fognitix::Timeline
