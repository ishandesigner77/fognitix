#include "VideoEngine.h"

#include "core/codec/VideoDecoder.h"
#include "core/state/AppState.h"

#include <QImage>

namespace Fognitix::Engine {

VideoEngine::VideoEngine(Fognitix::State::AppState& state)
    : m_state(state)
{
}

VideoEngine::~VideoEngine() = default;

bool VideoEngine::openMedia(const QString& path, QString* errorOut)
{
    closeMedia();
    auto dec = std::make_unique<Fognitix::Codec::VideoDecoder>();
    if (!dec->open(path, errorOut)) {
        return false;
    }
    m_decoder = std::move(dec);
    m_mediaPath = path;
    refreshPreviewAt(0.0);
    return true;
}

void VideoEngine::closeMedia()
{
    if (m_decoder) {
        m_decoder->close();
    }
    m_decoder.reset();
    m_mediaPath.clear();
    m_state.setPreviewFrame({});
}

void VideoEngine::refreshPreviewAt(double seconds)
{
    if (!m_decoder) {
        return;
    }
    QString err;
    if (!m_decoder->seekSeconds(seconds, &err)) {
        m_state.setStatusMessage(err);
        return;
    }
    Fognitix::Codec::DecodedFrame frame;
    if (!m_decoder->readNextFrameDecoded(frame, &err)) {
        m_state.setStatusMessage(err);
        return;
    }
    QImage img(
        frame.rgba.data(),
        frame.width,
        frame.height,
        frame.width * 4,
        QImage::Format_RGBA8888);
    m_state.setPreviewFrame(img.copy());
}

} // namespace Fognitix::Engine
