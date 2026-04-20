#include "ThumbnailImageProvider.h"

#include "core/codec/VideoDecoder.h"

#include <QImage>

namespace Fognitix::UI {

ThumbnailImageProvider::ThumbnailImageProvider(PathResolver resolver)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_resolver(std::move(resolver))
{
}

QImage ThumbnailImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    const auto parts = id.split(QLatin1Char('|'));
    if (parts.size() < 4 || !m_resolver) {
        return {};
    }
    const QString mediaId = parts.at(0);
    const double t = parts.at(1).toDouble();
    int tw = parts.at(2).toInt();
    int th = parts.at(3).toInt();
    if (tw < 16) {
        tw = 80;
    }
    if (th < 16) {
        th = 48;
    }

    const QString path = m_resolver(mediaId);
    if (path.isEmpty()) {
        return {};
    }

    Fognitix::Codec::VideoDecoder dec;
    QString err;
    if (!dec.open(path, &err)) {
        return {};
    }
    if (!dec.seekSeconds(t, &err)) {
        return {};
    }
    Fognitix::Codec::DecodedFrame frame;
    if (!dec.readNextFrameDecoded(frame, &err)) {
        return {};
    }
    QImage img(
        frame.rgba.data(),
        frame.width,
        frame.height,
        frame.width * 4,
        QImage::Format_RGBA8888);
    img = img.copy();
    if (requestedSize.isValid() && requestedSize.width() > 0 && requestedSize.height() > 0) {
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    } else {
        img = img.scaled(tw, th, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    if (size) {
        *size = img.size();
    }
    return img;
}

} // namespace Fognitix::UI
