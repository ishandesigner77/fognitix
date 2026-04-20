#include "CacheManager.h"

namespace Fognitix::Engine {

CacheManager::CacheManager() = default;
CacheManager::~CacheManager() = default;

void CacheManager::insertImage(const QString& key, const QImage& image)
{
    m_map[key] = std::make_shared<QImage>(image);
}

std::shared_ptr<QImage> CacheManager::takeImage(const QString& key)
{
    auto it = m_map.find(key);
    if (it == m_map.end()) {
        return nullptr;
    }
    auto v = it->second;
    m_map.erase(it);
    return v;
}

} // namespace Fognitix::Engine
