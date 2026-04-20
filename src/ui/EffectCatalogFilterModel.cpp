#include "EffectCatalogFilterModel.h"

#include "EffectCatalogModel.h"

namespace Fognitix::UI {

EffectCatalogFilterModel::EffectCatalogFilterModel(QObject* parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
}

void EffectCatalogFilterModel::setFilterText(const QString& text)
{
    if (m_filterText == text) {
        return;
    }
    m_filterText = text;
    invalidateFilter();
    emit filterTextChanged();
}

void EffectCatalogFilterModel::setFavoriteIds(const QStringList& ids)
{
    if (m_favoriteIds == ids) {
        return;
    }
    m_favoriteIds = ids;
    invalidateFilter();
    emit favoriteIdsChanged();
}

void EffectCatalogFilterModel::setFavoritesOnly(bool on)
{
    if (m_favoritesOnly == on) {
        return;
    }
    m_favoritesOnly = on;
    invalidateFilter();
    emit favoritesOnlyChanged();
}

bool EffectCatalogFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const
{
    const QModelIndex idx = sourceModel()->index(sourceRow, 0, sourceParent);
    if (!idx.isValid()) {
        return false;
    }
    if (m_favoritesOnly) {
        const QString id = sourceModel()->data(idx, EffectCatalogModel::EffectIdRole).toString();
        if (!m_favoriteIds.contains(id)) {
            return false;
        }
    }
    if (m_filterText.isEmpty()) {
        return true;
    }
    const QString needle = m_filterText.toCaseFolded();
    const auto match = [&](int role) {
        return sourceModel()->data(idx, role).toString().toCaseFolded().contains(needle);
    };
    return match(EffectCatalogModel::EffectIdRole) || match(EffectCatalogModel::EffectNameRole)
        || match(EffectCatalogModel::CategoryRole) || match(EffectCatalogModel::ShaderRole);
}

} // namespace Fognitix::UI
