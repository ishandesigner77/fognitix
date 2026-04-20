#pragma once

#include <cstdint>
#include <vector>

namespace Fognitix::Engine {

class FrameProcessor {
public:
    FrameProcessor();
    ~FrameProcessor();

    void processRgba(int width, int height, std::vector<std::uint8_t>& rgba);
};

} // namespace Fognitix::Engine
