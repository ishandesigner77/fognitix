#include "GPUPipeline.h"

#include "OpenGLRenderer.h"
#include "VulkanRenderer.h"

namespace Fognitix::Engine {

GPUPipeline::GPUPipeline(OpenGLRenderer& gl, VulkanRenderer& vk)
    : m_gl(gl)
    , m_vk(vk)
{
    QString err;
    m_vulkanReady = m_vk.initialize(&err);
}

GPUPipeline::~GPUPipeline() = default;

void GPUPipeline::submitRgba(int width, int height, const std::uint8_t* rgba, QString* errorOut)
{
    if (m_preferVulkan && m_vulkanReady) {
        m_vk.uploadRgba(width, height, rgba);
        return;
    }
    if (m_preferVulkan && !m_vulkanReady && errorOut) {
        *errorOut = QStringLiteral("Vulkan unavailable; using OpenGL CPU staging");
    }
    m_gl.uploadRgba(width, height, rgba);
}

} // namespace Fognitix::Engine
