#pragma once

#include <cstdint>

#include <QString>

namespace Fognitix::Engine {

class OpenGLRenderer;
class VulkanRenderer;

class GPUPipeline {
public:
    explicit GPUPipeline(OpenGLRenderer& gl, VulkanRenderer& vk);
    ~GPUPipeline();

    void setPreferVulkan(bool on) noexcept { m_preferVulkan = on; }
    bool preferVulkan() const noexcept { return m_preferVulkan; }

    void submitRgba(int width, int height, const std::uint8_t* rgba, QString* errorOut);

private:
    OpenGLRenderer& m_gl;
    VulkanRenderer& m_vk;
    bool m_preferVulkan = true;
    bool m_vulkanReady = false;
};

} // namespace Fognitix::Engine
