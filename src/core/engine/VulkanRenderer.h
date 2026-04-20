#pragma once

#include <cstdint>
#include <vector>

#include <QString>

namespace Fognitix::Engine {

class VulkanRenderer {
public:
    VulkanRenderer();
    ~VulkanRenderer();

    bool initialize(QString* errorOut);
    void shutdown();

    void resize(int width, int height);
    void uploadRgba(int width, int height, const std::uint8_t* rgba);

    bool isActive() const noexcept { return m_active; }

private:
    bool m_active = false;
    int m_width = 0;
    int m_height = 0;
    std::vector<std::uint8_t> m_scratch;
    void* m_instance = nullptr;
};

} // namespace Fognitix::Engine
