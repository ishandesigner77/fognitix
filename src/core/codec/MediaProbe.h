#pragma once

#include <QString>

namespace Fognitix::Codec {

struct MediaProbeResult {
    double durationSec = 0.0;
    int width = 0;
    int height = 0;
    bool hasVideo = false;
    bool hasAudio = false;
};

bool probeMediaFile(const QString& path, MediaProbeResult& out, QString* errorOut);

} // namespace Fognitix::Codec
