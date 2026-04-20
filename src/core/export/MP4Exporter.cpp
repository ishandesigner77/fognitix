#include "MP4Exporter.h"

#include <vector>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
}

#include <QtLogging>

namespace Fognitix::Export {

bool MP4Exporter::remuxToMp4(const QString& inputPath, const QString& outputPath, QString* errorOut)
{
    AVFormatContext* in = nullptr;
    if (avformat_open_input(&in, inputPath.toUtf8().constData(), nullptr, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("open input failed");
        }
        return false;
    }
    if (avformat_find_stream_info(in, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("find stream info failed");
        }
        avformat_close_input(&in);
        return false;
    }

    AVFormatContext* out = nullptr;
    if (avformat_alloc_output_context2(&out, nullptr, "mp4", outputPath.toUtf8().constData()) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("alloc output failed");
        }
        avformat_close_input(&in);
        return false;
    }

    std::vector<int> streamIndexMap(in->nb_streams, -1);
    for (unsigned i = 0; i < in->nb_streams; ++i) {
        AVStream* inStream = in->streams[i];
        if (inStream->codecpar->codec_type != AVMEDIA_TYPE_VIDEO
            && inStream->codecpar->codec_type != AVMEDIA_TYPE_AUDIO) {
            continue;
        }
        AVStream* outStream = avformat_new_stream(out, nullptr);
        if (!outStream) {
            if (errorOut) {
                *errorOut = QStringLiteral("new stream failed");
            }
            avformat_free_context(out);
            avformat_close_input(&in);
            return false;
        }
        if (avcodec_parameters_copy(outStream->codecpar, inStream->codecpar) < 0) {
            if (errorOut) {
                *errorOut = QStringLiteral("copy codecpar failed");
            }
            avformat_free_context(out);
            avformat_close_input(&in);
            return false;
        }
        outStream->codecpar->codec_tag = 0;
        streamIndexMap[i] = static_cast<int>(out->nb_streams) - 1;
    }

    if (!(out->oformat->flags & AVFMT_NOFILE)) {
        if (avio_open(&out->pb, outputPath.toUtf8().constData(), AVIO_FLAG_WRITE) < 0) {
            if (errorOut) {
                *errorOut = QStringLiteral("avio_open failed");
            }
            avformat_free_context(out);
            avformat_close_input(&in);
            return false;
        }
    }

    if (avformat_write_header(out, nullptr) < 0) {
        if (errorOut) {
            *errorOut = QStringLiteral("write_header failed");
        }
        avformat_free_context(out);
        avformat_close_input(&in);
        return false;
    }

    AVPacket* pkt = av_packet_alloc();
    while (av_read_frame(in, pkt) >= 0) {
        const int inIndex = pkt->stream_index;
        if (inIndex < 0 || inIndex >= static_cast<int>(streamIndexMap.size()) || streamIndexMap[inIndex] < 0) {
            av_packet_unref(pkt);
            continue;
        }
        pkt->stream_index = streamIndexMap[inIndex];
        av_packet_rescale_ts(pkt, in->streams[inIndex]->time_base, out->streams[pkt->stream_index]->time_base);
        if (av_interleaved_write_frame(out, pkt) < 0) {
            if (errorOut) {
                *errorOut = QStringLiteral("write_frame failed");
            }
            av_packet_unref(pkt);
            av_packet_free(&pkt);
            av_write_trailer(out);
            avformat_close_input(&in);
            if (!(out->oformat->flags & AVFMT_NOFILE)) {
                avio_closep(&out->pb);
            }
            avformat_free_context(out);
            return false;
        }
        av_packet_unref(pkt);
    }
    av_packet_free(&pkt);

    av_write_trailer(out);
    if (!(out->oformat->flags & AVFMT_NOFILE)) {
        avio_closep(&out->pb);
    }
    avformat_free_context(out);
    avformat_close_input(&in);
    return true;
}

} // namespace Fognitix::Export
