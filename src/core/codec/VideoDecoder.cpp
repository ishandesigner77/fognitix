#include "VideoDecoder.h"

#include <climits>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libavutil/time.h>
#include <libswscale/swscale.h>
}

#include <QtLogging>

namespace Fognitix::Codec {

VideoDecoder::VideoDecoder() = default;

VideoDecoder::~VideoDecoder()
{
    close();
}

void VideoDecoder::close()
{
    if (m_sws) {
        sws_freeContext(m_sws);
        m_sws = nullptr;
    }
    if (m_video) {
        avcodec_free_context(&m_video);
    }
    if (m_fmt) {
        avformat_close_input(&m_fmt);
    }
    m_videoStream = -1;
    m_duration = 0.0;
}

bool VideoDecoder::open(const QString& path, QString* errorOut)
{
    close();

    if (avformat_open_input(&m_fmt, path.toUtf8().constData(), nullptr, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("avformat_open_input failed");
        }
        close();
        return false;
    }
    if (avformat_find_stream_info(m_fmt, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("avformat_find_stream_info failed");
        }
        close();
        return false;
    }

    m_videoStream = av_find_best_stream(m_fmt, AVMEDIA_TYPE_VIDEO, -1, -1, nullptr, 0);
    if (m_videoStream < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("No video stream");
        }
        close();
        return false;
    }

    AVStream* st = m_fmt->streams[m_videoStream];
    const AVCodec* codec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!codec) {
        if (errorOut) {
            *errorOut = QStringLiteral("Decoder not found");
        }
        close();
        return false;
    }
    m_video = avcodec_alloc_context3(codec);
    if (!m_video) {
        if (errorOut) {
            *errorOut = QStringLiteral("avcodec_alloc_context3 failed");
        }
        close();
        return false;
    }
    if (avcodec_parameters_to_context(m_video, st->codecpar) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("avcodec_parameters_to_context failed");
        }
        close();
        return false;
    }
    if (avcodec_open2(m_video, codec, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("avcodec_open2 failed");
        }
        close();
        return false;
    }

    if (st->duration > 0 && st->time_base.den > 0) {
        m_duration = (static_cast<double>(st->duration) * static_cast<double>(st->time_base.num))
            / static_cast<double>(st->time_base.den);
    } else if (m_fmt->duration > 0) {
        m_duration = static_cast<double>(m_fmt->duration) / static_cast<double>(AV_TIME_BASE);
    }

    return true;
}

bool VideoDecoder::seekSeconds(double seconds, QString* errorOut)
{
    if (!m_fmt || m_videoStream < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("Decoder not open");
        }
        return false;
    }
    const int64_t micro = static_cast<int64_t>(seconds * AV_TIME_BASE);
    if (avformat_seek_file(m_fmt, -1, INT64_MIN, micro, INT64_MAX, 0) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("seek failed");
        }
        return false;
    }
    avcodec_flush_buffers(m_video);
    return true;
}

bool VideoDecoder::readNextFrameDecoded(DecodedFrame& out, QString* errorOut)
{
    if (!m_fmt || !m_video) {
        if (errorOut) {
            *errorOut = QStringLiteral("Decoder not open");
        }
        return false;
    }

    AVPacket* pkt = av_packet_alloc();
    AVFrame* frame = av_frame_alloc();
    if (!pkt || !frame) {
        if (errorOut) {
            *errorOut = QStringLiteral("alloc failed");
        }
        av_packet_free(&pkt);
        av_frame_free(&frame);
        return false;
    }

    while (true) {
        const int read = av_read_frame(m_fmt, pkt);
        if (read < 0) {
            break;
        }
        if (pkt->stream_index != m_videoStream) {
            av_packet_unref(pkt);
            continue;
        }

        if (avcodec_send_packet(m_video, pkt) < 0) {
            av_packet_unref(pkt);
            continue;
        }
        av_packet_unref(pkt);

        while (avcodec_receive_frame(m_video, frame) == 0) {
            const int w = frame->width;
            const int h = frame->height;
            if (!m_sws) {
                m_sws = sws_getContext(
                    w,
                    h,
                    static_cast<AVPixelFormat>(frame->format),
                    w,
                    h,
                    AV_PIX_FMT_RGBA,
                    SWS_BILINEAR,
                    nullptr,
                    nullptr,
                    nullptr);
            }
            if (!m_sws) {
                av_frame_unref(frame);
                continue;
            }
            out.width = w;
            out.height = h;
            out.rgba.resize(static_cast<std::size_t>(av_image_get_buffer_size(AV_PIX_FMT_RGBA, w, h, 1)));
            uint8_t* dstData[4] = {out.rgba.data(), nullptr, nullptr, nullptr};
            int dstLinesize[4] = {w * 4, 0, 0, 0};
            sws_scale(m_sws, frame->data, frame->linesize, 0, h, dstData, dstLinesize);
            av_frame_unref(frame);
            av_packet_free(&pkt);
            av_frame_free(&frame);
            return true;
        }
    }

    av_packet_free(&pkt);
    av_frame_free(&frame);
    if (errorOut) {
        *errorOut = QStringLiteral("EOF or decode error");
    }
    return false;
}

} // namespace Fognitix::Codec
