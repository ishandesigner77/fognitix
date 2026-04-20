#pragma once

#include <optional>
#include <unordered_map>
#include <vector>

#include <QString>

#include <QJsonArray>
#include <QJsonObject>

namespace Fognitix::Effects {

struct EffectDescriptor {
    QString id;
    QString name;
    QString category;
    QString shader;
    QJsonArray parameters;
};

class EffectRegistry {
public:
    EffectRegistry();

    bool loadBundled(QString* errorOut);
    bool loadFromFile(const QString& path, QString* errorOut);

    const std::vector<EffectDescriptor>& effects() const noexcept { return m_effects; }
    std::optional<EffectDescriptor> findById(const QString& id) const;

private:
    std::vector<EffectDescriptor> m_effects;
    std::unordered_map<QString, std::size_t> m_index;
};

} // namespace Fognitix::Effects
