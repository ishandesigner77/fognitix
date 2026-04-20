#pragma once

#include <QSortFilterProxyModel>

namespace Fognitix::UI {

class EffectCatalogFilterModel : public QSortFilterProxyModel {
    Q_OBJECT
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(QStringList favoriteIds READ favoriteIds WRITE setFavoriteIds NOTIFY favoriteIdsChanged)
    Q_PROPERTY(bool favoritesOnly READ favoritesOnly WRITE setFavoritesOnly NOTIFY favoritesOnlyChanged)

public:
    explicit EffectCatalogFilterModel(QObject* parent = nullptr);

    QString filterText() const { return m_filterText; }
    void setFilterText(const QString& text);

    QStringList favoriteIds() const { return m_favoriteIds; }
    void setFavoriteIds(const QStringList& ids);

    bool favoritesOnly() const { return m_favoritesOnly; }
    void setFavoritesOnly(bool on);

signals:
    void filterTextChanged();
    void favoriteIdsChanged();
    void favoritesOnlyChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;

private:
    QString m_filterText;
    QStringList m_favoriteIds;
    bool m_favoritesOnly = false;
};

} // namespace Fognitix::UI
