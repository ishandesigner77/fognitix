#include "WaveformImageProvider.h"

#include "core/codec/WaveformExtractor.h"

namespace Fognitix::UI {

WaveformImageProvider::WaveformImageProvider(PathResolver resolver)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_resolver(std::move(resolver))
{
}

QImage WaveformImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    const auto parts = id.split(QLatin1Char('|'));
    if (parts.size() < 5 || !m_resolver) {
        return {};
    }
    const QString mediaId = parts.at(0);
    const double t0 = parts.at(1).toDouble();
    const double dur = parts.at(2).toDouble();
    int w = parts.at(3).toInt();
    int h = parts.at(4).toInt();
    if (w < 8) {
        w = 200;
    }
    if (h < 8) {
        h = 40;
    }

    const QString path = m_resolver(mediaId);
    if (path.isEmpty()) {
        return {};
    }

    QString err;
    QImage img = Fognitix::Codec::renderAudioWaveform(path, t0, dur, w, h, &err);
    if (requestedSize.isValid() && requestedSize.width() > 0 && requestedSize.height() > 0) {
        img = img.scaled(requestedSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    }
    if (size && !img.isNull()) {
        *size = img.size();
    }
    return img;
}

} // namespace Fognitix::UI
