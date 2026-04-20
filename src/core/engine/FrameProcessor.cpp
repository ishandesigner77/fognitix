#include "FrameProcessor.h"

#include <cstring>

#if FOGNITIX_HAVE_OPENCV
#include <opencv2/imgproc.hpp>
#endif

namespace Fognitix::Engine {

FrameProcessor::FrameProcessor() = default;
FrameProcessor::~FrameProcessor() = default;

void FrameProcessor::processRgba(int width, int height, std::vector<std::uint8_t>& rgba)
{
#if FOGNITIX_HAVE_OPENCV
    if (width <= 0 || height <= 0 || rgba.empty()) {
        return;
    }
    cv::Mat src(height, width, CV_8UC4, rgba.data());
    cv::Mat dst;
    cv::GaussianBlur(src, dst, cv::Size(3, 3), 0);
    std::memcpy(rgba.data(), dst.data, rgba.size());
#else
    (void)width;
    (void)height;
#endif
}

} // namespace Fognitix::Engine
