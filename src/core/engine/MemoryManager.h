#pragma once

#include <cstddef>
#include <cstdint>

namespace Fognitix::Engine {

class MemoryManager {
public:
    MemoryManager();
    ~MemoryManager();

    void* allocate(std::size_t bytes);
    void deallocate(void* ptr, std::size_t bytes);

    std::uint64_t bytesInUse() const noexcept { return m_bytes; }

private:
    std::uint64_t m_bytes = 0;
};

} // namespace Fognitix::Engine
