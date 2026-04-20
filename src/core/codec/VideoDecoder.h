#pragma once

#include <cstdint>
#include <memory>
#include <vector>

#include <QString>

struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;
struct SwsContext;

namespace Fognitix::Codec {

struct DecodedFrame {
    int width = 0;
    int height = 0;
    std::vector<uint8_t> rgba;
};

class VideoDecoder {
public:
    VideoDecoder();
    ~VideoDecoder();

    bool open(const QString& path, QString* errorOut);
    void close();

    bool seekSeconds(double seconds, QString* errorOut);
    bool readNextFrameDecoded(DecodedFrame& out, QString* errorOut);

    double durationSeconds() const noexcept { return m_duration; }

private:
    AVFormatContext* m_fmt = nullptr;
    AVCodecContext* m_video = nullptr;
    int m_videoStream = -1;
    SwsContext* m_sws = nullptr;
    double m_duration = 0.0;
};

} // namespace Fognitix::Codec
