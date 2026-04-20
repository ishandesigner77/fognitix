#include "MediaProbe.h"

extern "C" {
#include <libavformat/avformat.h>
#include <libavutil/time.h>
}

namespace Fognitix::Codec {

bool probeMediaFile(const QString& path, MediaProbeResult& out, QString* errorOut)
{
    out = MediaProbeResult{};
    AVFormatContext* fmt = nullptr;
    const QByteArray p = path.toUtf8();
    if (avformat_open_input(&fmt, p.constData(), nullptr, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("Could not open media file");
        }
        return false;
    }
    if (avformat_find_stream_info(fmt, nullptr) < 0) {
        avformat_close_input(&fmt);
        if (errorOut) {
            *errorOut = QStringLiteral("Could not read stream info");
        }
        return false;
    }

    if (fmt->duration > 0) {
        out.durationSec = static_cast<double>(fmt->duration) / static_cast<double>(AV_TIME_BASE);
    }

    const int vs = av_find_best_stream(fmt, AVMEDIA_TYPE_VIDEO, -1, -1, nullptr, 0);
    if (vs >= 0) {
        out.hasVideo = true;
        const AVCodecParameters* par = fmt->streams[vs]->codecpar;
        out.width = par->width;
        out.height = par->height;
    }

    const int as = av_find_best_stream(fmt, AVMEDIA_TYPE_AUDIO, -1, -1, nullptr, 0);
    if (as >= 0) {
        out.hasAudio = true;
    }

    avformat_close_input(&fmt);
    return true;
}

} // namespace Fognitix::Codec
