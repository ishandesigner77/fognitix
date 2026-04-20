#pragma once

#include <memory>

#include <QString>

namespace Fognitix::Codec {
class VideoDecoder;
}

namespace Fognitix::State {
class AppState;
}

namespace Fognitix::Engine {

class VideoEngine {
public:
    explicit VideoEngine(Fognitix::State::AppState& state);
    ~VideoEngine();

    bool openMedia(const QString& path, QString* errorOut);
    void closeMedia();

    void refreshPreviewAt(double seconds);

    const QString& currentMediaPath() const noexcept { return m_mediaPath; }

private:
    Fognitix::State::AppState& m_state;
    std::unique_ptr<Fognitix::Codec::VideoDecoder> m_decoder;
    QString m_mediaPath;
};

} // namespace Fognitix::Engine
