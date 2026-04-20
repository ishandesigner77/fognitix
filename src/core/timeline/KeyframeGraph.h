#pragma once

#include <vector>

#include <QString>

#include "Keyframe.h"

namespace Fognitix::Timeline {

class KeyframeGraph {
public:
    void setKeyframes(QString parameterId, std::vector<Keyframe> frames);
    const std::vector<Keyframe>& keyframes(const QString& parameterId) const;

    QJsonObject toJson() const;
    void loadFromJson(const QJsonObject& obj);

private:
    std::vector<std::pair<QString, std::vector<Keyframe>>> m_channels;
};

} // namespace Fognitix::Timeline
