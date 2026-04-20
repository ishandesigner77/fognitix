#include "RenderEngine.h"

#include "GPUPipeline.h"
#include "OpenGLRenderer.h"
#include "VulkanRenderer.h"

namespace Fognitix::Engine {

RenderEngine::RenderEngine()
    : m_gl(std::make_unique<OpenGLRenderer>())
    , m_vk(std::make_unique<VulkanRenderer>())
    , m_pipeline(std::make_unique<GPUPipeline>(*m_gl, *m_vk))
{
}

RenderEngine::~RenderEngine() = default;

void RenderEngine::presentRgba(int width, int height, const std::uint8_t* rgba, QString* errorOut)
{
    m_pipeline->submitRgba(width, height, rgba, errorOut);
}

} // namespace Fognitix::Engine
