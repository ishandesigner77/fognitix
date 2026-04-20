#pragma once

#include <memory>

#include <QString>

namespace Fognitix::Engine {

class OpenGLRenderer;
class VulkanRenderer;
class GPUPipeline;

class RenderEngine {
public:
    RenderEngine();
    ~RenderEngine();

    GPUPipeline& pipeline() noexcept { return *m_pipeline; }

    void presentRgba(int width, int height, const std::uint8_t* rgba, QString* errorOut);

private:
    std::unique_ptr<OpenGLRenderer> m_gl;
    std::unique_ptr<VulkanRenderer> m_vk;
    std::unique_ptr<GPUPipeline> m_pipeline;
};

} // namespace Fognitix::Engine
