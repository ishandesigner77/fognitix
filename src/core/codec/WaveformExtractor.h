#pragma once

#include <QImage>
#include <QString>

namespace Fognitix::Codec {

QImage renderAudioWaveform(
    const QString& mediaPath,
    double startSec,
    double durationSec,
    int pixelWidth,
    int pixelHeight,
    QString* errorOut);

} // namespace Fognitix::Codec
