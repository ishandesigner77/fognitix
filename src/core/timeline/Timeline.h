#pragma once

#include <optional>
#include <vector>

#include <QString>
#include <QJsonObject>

#include "TimelineTrack.h"

namespace Fognitix::Timeline {

class Timeline {
public:
    Timeline();
    ~Timeline();

    const std::vector<TimelineTrack>& tracks() const noexcept { return m_tracks; }
    std::vector<TimelineTrack>& tracks() noexcept { return m_tracks; }

    QJsonObject toJson() const;
    void loadFromJson(const QJsonObject& obj);

    std::optional<TimelineClip*> findClip(const QString& clipId) noexcept;
    std::optional<const TimelineClip*> findClip(const QString& clipId) const noexcept;

    QString addTrack(const QString& name, TrackType type, int heightPx = 52, const QString& labelColor = {});
    QString addVideoTrack(const QString& name);
    QString addAudioTrack(const QString& name);
    QString addClip(const QString& trackId, const QString& mediaId, double start, double duration);

private:
    std::vector<TimelineTrack> m_tracks;
    quint64 m_nextId = 1;
};

} // namespace Fognitix::Timeline
