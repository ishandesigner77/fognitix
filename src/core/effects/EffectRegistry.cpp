#include "EffectRegistry.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace Fognitix::Effects {

EffectRegistry::EffectRegistry() = default;

bool EffectRegistry::loadFromFile(const QString& path, QString* errorOut)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        if (errorOut) {
            *errorOut = QStringLiteral("Cannot open ") + path;
        }
        return false;
    }
    const QByteArray raw = f.readAll();
    QJsonParseError pe{};
    const QJsonDocument doc = QJsonDocument::fromJson(raw, &pe);
    if (pe.error != QJsonParseError::NoError || !doc.isObject()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Invalid registry JSON");
        }
        return false;
    }
    const QJsonObject root = doc.object();
    const QJsonArray arr = root.value(QStringLiteral("effects")).toArray();
    m_effects.clear();
    m_index.clear();
    m_effects.reserve(static_cast<std::size_t>(arr.size()));
    for (const auto& v : arr) {
        if (!v.isObject()) {
            continue;
        }
        const QJsonObject o = v.toObject();
        EffectDescriptor d;
        d.id = o.value(QStringLiteral("id")).toString();
        d.name = o.value(QStringLiteral("name")).toString();
        d.category = o.value(QStringLiteral("category")).toString();
        d.shader = o.value(QStringLiteral("shader")).toString();
        d.parameters = o.value(QStringLiteral("parameters")).toArray();
        if (d.id.isEmpty()) {
            continue;
        }
        m_index[d.id] = m_effects.size();
        m_effects.push_back(std::move(d));
    }
    return !m_effects.empty();
}

bool EffectRegistry::loadBundled(QString* errorOut)
{
    return loadFromFile(QStringLiteral(":/effects/registry.generated.json"), errorOut);
}

std::optional<EffectDescriptor> EffectRegistry::findById(const QString& id) const
{
    auto it = m_index.find(id);
    if (it == m_index.end()) {
        return std::nullopt;
    }
    return m_effects.at(it->second);
}

} // namespace Fognitix::Effects
