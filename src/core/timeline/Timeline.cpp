#include "Timeline.h"

#include <QUuid>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace Fognitix::Timeline {

Timeline::Timeline() = default;
Timeline::~Timeline() = default;

QString Timeline::addTrack(const QString& name, TrackType type, int heightPx, const QString& labelColor)
{
    TimelineTrack t;
    t.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    t.name = name;
    t.type = type;
    t.sortIndex = static_cast<int>(m_tracks.size());
    int h = heightPx > 0 ? heightPx : 52;
    if (h < 30) {
        h = 30;
    }
    if (h > 200) {
        h = 200;
    }
    t.heightPx = h;
    t.labelColor = labelColor;
    m_tracks.push_back(std::move(t));
    return m_tracks.back().id;
}

QString Timeline::addVideoTrack(const QString& name)
{
    const QString n = name.isEmpty() ? QStringLiteral("V1") : name;
    return addTrack(n, TrackType::Video, 52, {});
}

QString Timeline::addAudioTrack(const QString& name)
{
    const QString n = name.isEmpty() ? QStringLiteral("A1") : name;
    return addTrack(n, TrackType::Audio, 52, {});
}

QString Timeline::addClip(const QString& trackId, const QString& mediaId, double start, double duration)
{
    for (auto& tr : m_tracks) {
        if (tr.id != trackId) {
            continue;
        }
        TimelineClip c;
        c.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
        c.trackId = trackId;
        c.mediaId = mediaId;
        c.startOnTimeline = start;
        c.duration = duration;
        c.sourceInPoint = 0.0;
        c.speed = 1.0;
        tr.clips.push_back(std::move(c));
        return tr.clips.back().id;
    }
    return {};
}

std::optional<TimelineClip*> Timeline::findClip(const QString& clipId) noexcept
{
    for (auto& tr : m_tracks) {
        for (auto& c : tr.clips) {
            if (c.id == clipId) {
                return &c;
            }
        }
    }
    return std::nullopt;
}

std::optional<const TimelineClip*> Timeline::findClip(const QString& clipId) const noexcept
{
    for (const auto& tr : m_tracks) {
        for (const auto& c : tr.clips) {
            if (c.id == clipId) {
                return &c;
            }
        }
    }
    return std::nullopt;
}

QJsonObject Timeline::toJson() const
{
    QJsonArray tracks;
    for (const auto& tr : m_tracks) {
        QJsonArray clips;
        for (const auto& c : tr.clips) {
            QJsonObject o;
            o.insert("id", c.id);
            o.insert("track_id", c.trackId);
            o.insert("media_id", c.mediaId);
            o.insert("start", c.startOnTimeline);
            o.insert("duration", c.duration);
            o.insert("source_in", c.sourceInPoint);
            o.insert("speed", c.speed);
            o.insert("effects", c.effectStack);
            clips.append(o);
        }
        QJsonObject t;
        t.insert("id", tr.id);
        t.insert("name", tr.name);
        t.insert("type", static_cast<int>(tr.type));
        t.insert("sort", tr.sortIndex);
        t.insert("height_px", tr.heightPx);
        if (!tr.labelColor.isEmpty()) {
            t.insert("label_color", tr.labelColor);
        }
        t.insert("clips", clips);
        tracks.append(t);
    }
    QJsonObject root;
    root.insert("tracks", tracks);
    return root;
}

void Timeline::loadFromJson(const QJsonObject& obj)
{
    m_tracks.clear();
    const QJsonArray tracks = obj.value("tracks").toArray();
    for (const auto& tv : tracks) {
        const QJsonObject t = tv.toObject();
        TimelineTrack tr;
        tr.id = t.value("id").toString();
        tr.name = t.value("name").toString();
        const int typeInt = t.value("type").toInt(0);
        if (typeInt >= 0 && typeInt <= 3) {
            tr.type = static_cast<TrackType>(typeInt);
        } else {
            tr.type = TrackType::Video;
        }
        tr.sortIndex = t.value("sort").toInt(0);
        tr.heightPx = t.value("height_px").toInt(52);
        if (tr.heightPx < 30) {
            tr.heightPx = 30;
        }
        if (tr.heightPx > 200) {
            tr.heightPx = 200;
        }
        tr.labelColor = t.value("label_color").toString();
        const QJsonArray clips = t.value("clips").toArray();
        for (const auto& cv : clips) {
            const QJsonObject c = cv.toObject();
            TimelineClip clip;
            clip.id = c.value("id").toString();
            clip.trackId = c.value("track_id").toString();
            clip.mediaId = c.value("media_id").toString();
            clip.startOnTimeline = c.value("start").toDouble();
            clip.duration = c.value("duration").toDouble();
            clip.sourceInPoint = c.value("source_in").toDouble();
            clip.speed = c.value("speed").toDouble(1.0);
            clip.effectStack = c.value("effects").toArray();
            tr.clips.push_back(std::move(clip));
        }
        m_tracks.push_back(std::move(tr));
    }
}

} // namespace Fognitix::Timeline
