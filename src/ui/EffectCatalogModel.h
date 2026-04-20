#pragma once

#include <QAbstractListModel>
#include <QVector>

#include <QString>

namespace Fognitix::Effects {
struct EffectDescriptor;
}

namespace Fognitix::UI {

class EffectCatalogModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Role { EffectIdRole = Qt::UserRole + 1, EffectNameRole, CategoryRole, ShaderRole };

    explicit EffectCatalogModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void rebuild(const std::vector<Fognitix::Effects::EffectDescriptor>& effects);

private:
    struct Row {
        QString id;
        QString name;
        QString category;
        QString shader;
    };
    QVector<Row> m_rows;
};

} // namespace Fognitix::UI
