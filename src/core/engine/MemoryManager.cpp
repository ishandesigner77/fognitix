#include "MemoryManager.h"

#include <cstdlib>

namespace Fognitix::Engine {

MemoryManager::MemoryManager() = default;
MemoryManager::~MemoryManager() = default;

void* MemoryManager::allocate(std::size_t bytes)
{
    void* p = std::malloc(bytes);
    if (p) {
        m_bytes += bytes;
    }
    return p;
}

void MemoryManager::deallocate(void* ptr, std::size_t bytes)
{
    if (!ptr) {
        return;
    }
    std::free(ptr);
    if (m_bytes >= bytes) {
        m_bytes -= bytes;
    } else {
        m_bytes = 0;
    }
}

} // namespace Fognitix::Engine
