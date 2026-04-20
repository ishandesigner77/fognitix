#include "OpenGLRenderer.h"

#include <cstring>

namespace Fognitix::Engine {

OpenGLRenderer::OpenGLRenderer() = default;
OpenGLRenderer::~OpenGLRenderer() = default;

void OpenGLRenderer::resize(int width, int height)
{
    m_width = width;
    m_height = height;
}

void OpenGLRenderer::uploadRgba(int width, int height, const std::uint8_t* rgba)
{
    if (!rgba || width <= 0 || height <= 0) {
        return;
    }
    const std::size_t bytes = static_cast<std::size_t>(width) * static_cast<std::size_t>(height) * 4u;
    m_scratch.resize(bytes);
    std::memcpy(m_scratch.data(), rgba, bytes);
    m_width = width;
    m_height = height;
}

} // namespace Fognitix::Engine
