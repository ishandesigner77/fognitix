#pragma once

#include <cstdint>
#include <vector>

namespace Fognitix::Engine {

class OpenGLRenderer {
public:
    OpenGLRenderer();
    ~OpenGLRenderer();

    void resize(int width, int height);
    void uploadRgba(int width, int height, const std::uint8_t* rgba);

    int width() const noexcept { return m_width; }
    int height() const noexcept { return m_height; }

private:
    int m_width = 0;
    int m_height = 0;
    std::vector<std::uint8_t> m_scratch;
};

} // namespace Fognitix::Engine
