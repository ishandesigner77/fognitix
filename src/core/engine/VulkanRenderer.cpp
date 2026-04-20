#include "VulkanRenderer.h"

#include <cstring>

#include <QtLogging>

#if FOGNITIX_HAVE_VULKAN
#include <vulkan/vulkan.h>
#endif

namespace Fognitix::Engine {

VulkanRenderer::VulkanRenderer() = default;

VulkanRenderer::~VulkanRenderer()
{
    shutdown();
}

bool VulkanRenderer::initialize(QString* errorOut)
{
#if FOGNITIX_HAVE_VULKAN
    if (m_instance) {
        m_active = true;
        return true;
    }
    VkApplicationInfo appInfo{};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Fognitix";
    appInfo.applicationVersion = VK_MAKE_VERSION(0, 1, 0);
    appInfo.pEngineName = "Fognitix";
    appInfo.engineVersion = VK_MAKE_VERSION(0, 1, 0);
    appInfo.apiVersion = VK_API_VERSION_1_2;

    VkInstanceCreateInfo createInfo{};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;

    VkInstance instance = VK_NULL_HANDLE;
    if (vkCreateInstance(&createInfo, nullptr, &instance) != VK_SUCCESS) {
        if (errorOut) {
            *errorOut = QStringLiteral("vkCreateInstance failed");
        }
        m_active = false;
        return false;
    }
    m_instance = instance;
    m_active = true;
    return true;
#else
    if (errorOut) {
        *errorOut = QStringLiteral("Vulkan not enabled in this build");
    }
    m_active = false;
    return false;
#endif
}

void VulkanRenderer::shutdown()
{
#if FOGNITIX_HAVE_VULKAN
    if (m_instance) {
        vkDestroyInstance(reinterpret_cast<VkInstance>(m_instance), nullptr);
        m_instance = nullptr;
    }
#else
    m_instance = nullptr;
#endif
    m_active = false;
    m_scratch.clear();
}

void VulkanRenderer::resize(int width, int height)
{
    m_width = width;
    m_height = height;
}

void VulkanRenderer::uploadRgba(int width, int height, const std::uint8_t* rgba)
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
