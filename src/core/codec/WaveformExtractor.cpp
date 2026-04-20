#include "WaveformExtractor.h"

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
}

#include <cmath>
#include <vector>

#include <QtGlobal>

namespace Fognitix::Codec {

namespace {

void drawPeaks(QImage& img, const std::vector<float>& peaks, QRgb waveRgb, QRgb bgRgb)
{
    const int w = img.width();
    const int h = img.height();
    for (int y = 0; y < h; ++y) {
        auto* line = reinterpret_cast<QRgb*>(img.scanLine(y));
        for (int x = 0; x < w; ++x) {
            line[x] = bgRgb;
        }
    }
    const int mid = h / 2;
    const float gain = static_cast<float>(h) * 0.42f;
    for (int x = 0; x < w && x < static_cast<int>(peaks.size()); ++x) {
        const float pk = std::clamp(peaks[static_cast<std::size_t>(x)], 0.0f, 1.0f);
        const int amp = std::max(1, static_cast<int>(pk * gain));
        const int y0 = std::max(0, mid - amp);
        const int y1 = std::min(h - 1, mid + amp);
        for (int y = y0; y <= y1; ++y) {
            reinterpret_cast<QRgb*>(img.scanLine(y))[x] = waveRgb;
        }
    }
}

} // namespace

QImage renderAudioWaveform(
    const QString& mediaPath,
    double startSec,
    double durationSec,
    int pixelWidth,
    int pixelHeight,
    QString* errorOut)
{
    if (pixelWidth < 2 || pixelHeight < 8 || durationSec <= 0.0) {
        return {};
    }

    QImage img(pixelWidth, pixelHeight, QImage::Format_ARGB32_Premultiplied);
    img.fill(QColor(10, 40, 22));

    AVFormatContext* fmt = nullptr;
    const QByteArray p = mediaPath.toUtf8();
    if (avformat_open_input(&fmt, p.constData(), nullptr, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("open failed");
        }
        return img;
    }
    if (avformat_find_stream_info(fmt, nullptr) < 0) {
        avformat_close_input(&fmt);
        if (errorOut) {
            *errorOut = QStringLiteral("stream info failed");
        }
        return img;
    }

    const int as = av_find_best_stream(fmt, AVMEDIA_TYPE_AUDIO, -1, -1, nullptr, 0);
    if (as < 0) {
        avformat_close_input(&fmt);
        if (errorOut) {
            *errorOut = QStringLiteral("no audio");
        }
        return img;
    }

    AVStream* st = fmt->streams[as];
    const AVCodec* codec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!codec) {
        avformat_close_input(&fmt);
        if (errorOut) {
            *errorOut = QStringLiteral("no decoder");
        }
        return img;
    }

    AVCodecContext* actx = avcodec_alloc_context3(codec);
    if (!actx) {
        avformat_close_input(&fmt);
        return img;
    }
    if (avcodec_parameters_to_context(actx, st->codecpar) < 0) {
        avcodec_free_context(&actx);
        avformat_close_input(&fmt);
        return img;
    }
    if (avcodec_open2(actx, codec, nullptr) < 0) {
        avcodec_free_context(&actx);
        avformat_close_input(&fmt);
        return img;
    }

    const int64_t seekTs = static_cast<int64_t>(startSec / av_q2d(st->time_base));
    av_seek_frame(fmt, as, seekTs, AVSEEK_FLAG_BACKWARD);

    avcodec_flush_buffers(actx);

    std::vector<float> bucketMax(static_cast<std::size_t>(pixelWidth), 0.0f);
    std::vector<int> bucketCount(static_cast<std::size_t>(pixelWidth), 0);

    AVPacket* pkt = av_packet_alloc();
    AVFrame* frame = av_frame_alloc();
    if (!pkt || !frame) {
        av_packet_free(&pkt);
        av_frame_free(&frame);
        avcodec_free_context(&actx);
        avformat_close_input(&fmt);
        return img;
    }

    const double tb = av_q2d(st->time_base);
    const double endT = startSec + durationSec;
    bool gotAny = false;

    while (av_read_frame(fmt, pkt) >= 0) {
        if (pkt->stream_index != as) {
            av_packet_unref(pkt);
            continue;
        }
        if (avcodec_send_packet(actx, pkt) < 0) {
            av_packet_unref(pkt);
            continue;
        }
        av_packet_unref(pkt);

        while (avcodec_receive_frame(actx, frame) == 0) {
            const double ptsSec = (frame->pts != AV_NOPTS_VALUE) ? frame->pts * tb : startSec;
            if (ptsSec > endT + 0.5) {
                av_frame_unref(frame);
                goto done_decode;
            }
            if (ptsSec + 0.05 < startSec) {
                av_frame_unref(frame);
                continue;
            }
            gotAny = true;
            const int nb = frame->nb_samples;
            const int ch = actx->ch_layout.nb_channels > 0 ? actx->ch_layout.nb_channels : 1;
            if (nb <= 0 || ch <= 0) {
                av_frame_unref(frame);
                continue;
            }

            for (int i = 0; i < nb; ++i) {
                const double t = ptsSec + (static_cast<double>(i) / static_cast<double>(actx->sample_rate));
                if (t < startSec || t > endT) {
                    continue;
                }
                const double u = (t - startSec) / durationSec;
                const int bx = static_cast<int>(u * (pixelWidth - 1));
                if (bx < 0 || bx >= pixelWidth) {
                    continue;
                }
                float s = 0.0f;
                if (frame->format == AV_SAMPLE_FMT_FLTP) {
                    const float* plane = reinterpret_cast<const float*>(frame->data[0]);
                    s = std::abs(plane[i]);
                } else if (frame->format == AV_SAMPLE_FMT_S16) {
                    const int16_t* plane = reinterpret_cast<const int16_t*>(frame->data[0]);
                    s = std::abs(static_cast<float>(plane[i * ch])) / 32768.0f;
                } else {
                    continue;
                }
                const std::size_t bi = static_cast<std::size_t>(bx);
                bucketMax[bi] = std::max(bucketMax[bi], s);
                bucketCount[bi] += 1;
            }
            av_frame_unref(frame);
        }
    }

done_decode:
    av_packet_free(&pkt);
    av_frame_free(&frame);
    avcodec_free_context(&actx);
    avformat_close_input(&fmt);

    if (!gotAny) {
        if (errorOut) {
            *errorOut = QStringLiteral("no samples decoded");
        }
    }

    std::vector<float> peaks(static_cast<std::size_t>(pixelWidth), 0.0f);
    for (int x = 0; x < pixelWidth; ++x) {
        const std::size_t xi = static_cast<std::size_t>(x);
        peaks[xi] = bucketMax[xi];
    }
    drawPeaks(img, peaks, qRgb(180, 255, 200), qRgb(12, 56, 28));
    return img;
}

} // namespace Fognitix::Codec
