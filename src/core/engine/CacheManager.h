#pragma once

#include <memory>
#include <unordered_map>

#include <QString>

#include <QImage>

namespace Fognitix::Engine {

class CacheManager {
public:
    CacheManager();
    ~CacheManager();

    void insertImage(const QString& key, const QImage& image);
    std::shared_ptr<QImage> takeImage(const QString& key);

private:
    std::unordered_map<QString, std::shared_ptr<QImage>> m_map;
};

} // namespace Fognitix::Engine
