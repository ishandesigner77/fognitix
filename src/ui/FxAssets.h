#pragma once

#include <QHash>
#include <QObject>
#include <QString>

namespace Fognitix::UI {

/// Resolves PNG packs from install dir and %AppData%/Fognitix/assets (recursive).
class FxAssets : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString localPngDirectory READ localPngDirectory NOTIFY manifestChanged)
    Q_PROPERTY(int assetManifestCount READ assetManifestCount NOTIFY manifestChanged)

public:
    explicit FxAssets(QObject* parent = nullptr);

    QString localPngDirectory() const { return m_primaryDir; }
    int assetManifestCount() const { return m_manifest.size(); }

    Q_INVOKABLE QString urlFor(const QString& fileName) const;
    Q_INVOKABLE bool exists(const QString& fileName) const;
    Q_INVOKABLE QString manifestUrl(const QString& category, const QString& baseName) const;

signals:
    void manifestChanged();

private:
    void rebuildManifest();

    QString m_primaryDir;
    QHash<QString, QString> m_manifest; // key: "effect/foo" value: file:// path
};

} // namespace Fognitix::UI
