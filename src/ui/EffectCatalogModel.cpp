#include "EffectCatalogModel.h"

#include "core/effects/EffectRegistry.h"

namespace Fognitix::UI {

EffectCatalogModel::EffectCatalogModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int EffectCatalogModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_rows.size();
}

QVariant EffectCatalogModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_rows.size()) {
        return {};
    }
    const Row& r = m_rows.at(index.row());
    switch (role) {
    case EffectIdRole:
        return r.id;
    case EffectNameRole:
        return r.name;
    case CategoryRole:
        return r.category;
    case ShaderRole:
        return r.shader;
    default:
        return {};
    }
}

QHash<int, QByteArray> EffectCatalogModel::roleNames() const
{
    return {
        {EffectIdRole, QByteArrayLiteral("effectId")},
        {EffectNameRole, QByteArrayLiteral("effectName")},
        {CategoryRole, QByteArrayLiteral("effectCategory")},
        {ShaderRole, QByteArrayLiteral("effectShader")},
    };
}

void EffectCatalogModel::rebuild(const std::vector<Fognitix::Effects::EffectDescriptor>& effects)
{
    beginResetModel();
    m_rows.clear();
    m_rows.reserve(static_cast<int>(effects.size()));
    for (const auto& e : effects) {
        Row r;
        r.id = e.id;
        r.name = e.name;
        r.category = e.category;
        r.shader = e.shader;
        m_rows.append(std::move(r));
    }
    endResetModel();
}

} // namespace Fognitix::UI
