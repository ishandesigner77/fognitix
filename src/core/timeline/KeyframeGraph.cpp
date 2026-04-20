#include "KeyframeGraph.h"

#include <QJsonArray>
#include <QJsonObject>

namespace Fognitix::Timeline {

void KeyframeGraph::setKeyframes(QString parameterId, std::vector<Keyframe> frames)
{
    for (auto& ch : m_channels) {
        if (ch.first == parameterId) {
            ch.second = std::move(frames);
            return;
        }
    }
    m_channels.push_back({std::move(parameterId), std::move(frames)});
}

const std::vector<Keyframe>& KeyframeGraph::keyframes(const QString& parameterId) const
{
    static const std::vector<Keyframe> empty;
    for (const auto& ch : m_channels) {
        if (ch.first == parameterId) {
            return ch.second;
        }
    }
    return empty;
}

QJsonObject KeyframeGraph::toJson() const
{
    QJsonObject root;
    for (const auto& ch : m_channels) {
        QJsonArray arr;
        for (const auto& k : ch.second) {
            QJsonObject o;
            o.insert("time", k.time);
            o.insert("parameter", k.parameterId);
            o.insert("value", k.value);
            o.insert("easing", k.easing);
            arr.append(o);
        }
        root.insert(ch.first, arr);
    }
    return root;
}

void KeyframeGraph::loadFromJson(const QJsonObject& obj)
{
    m_channels.clear();
    for (auto it = obj.begin(); it != obj.end(); ++it) {
        std::vector<Keyframe> frames;
        const QJsonArray arr = it.value().toArray();
        for (const auto& v : arr) {
            const QJsonObject o = v.toObject();
            Keyframe k;
            k.time = o.value("time").toDouble();
            k.parameterId = o.value("parameter").toString();
            k.value = o.value("value");
            k.easing = o.value("easing").toString(QStringLiteral("linear"));
            frames.push_back(std::move(k));
        }
        m_channels.push_back({it.key(), std::move(frames)});
    }
}

} // namespace Fognitix::Timeline
