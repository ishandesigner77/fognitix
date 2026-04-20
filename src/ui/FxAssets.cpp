#include "FxAssets.h"

#include <QCoreApplication>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>

namespace Fognitix::UI {

namespace {

void insertPrefix(QHash<QString, QString>& map, const QString& prefix, const QString& path)
{
    const QFileInfo fi(path);
    const QString base = fi.completeBaseName();
    if (base.startsWith(prefix + QLatin1Char('_'))) {
        const QString key = prefix + QLatin1Char('/') + base.mid(prefix.length() + 1);
        map.insert(key, QUrl::fromLocalFile(path).toString());
    }
}

void scanDir(const QString& root, QHash<QString, QString>& map)
{
    if (root.isEmpty() || !QDir(root).exists()) {
        return;
    }
    QDirIterator it(root, QStringList() << QStringLiteral("*.png") << QStringLiteral("*.PNG"),
        QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const QString path = it.next();
        const QString lower = QFileInfo(path).fileName().toLower();
        if (lower.startsWith(QStringLiteral("effect_"))) {
            insertPrefix(map, QStringLiteral("effect"), path);
        } else if (lower.startsWith(QStringLiteral("transition_"))) {
            insertPrefix(map, QStringLiteral("transition"), path);
        } else if (lower.startsWith(QStringLiteral("icon_"))) {
            insertPrefix(map, QStringLiteral("icon"), path);
        } else if (lower.startsWith(QStringLiteral("lut_"))) {
            insertPrefix(map, QStringLiteral("lut"), path);
        } else if (lower.startsWith(QStringLiteral("template_"))) {
            insertPrefix(map, QStringLiteral("template"), path);
        }
    }
}

} // namespace

FxAssets::FxAssets(QObject* parent)
    : QObject(parent)
{
    m_primaryDir = QDir(QCoreApplication::applicationDirPath()).absoluteFilePath(QStringLiteral("PNG"));
    rebuildManifest();
}

void FxAssets::rebuildManifest()
{
    m_manifest.clear();
    scanDir(m_primaryDir, m_manifest);

    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    const QString userAssets = QDir(appData).absoluteFilePath(QStringLiteral("assets"));
    scanDir(userAssets, m_manifest);

    const QString installAssets = QDir(QCoreApplication::applicationDirPath()).absoluteFilePath(QStringLiteral("assets"));
    scanDir(installAssets, m_manifest);

    emit manifestChanged();
}

QString FxAssets::urlFor(const QString& fileName) const
{
    if (fileName.isEmpty()) {
        return {};
    }
    const QString path = QDir(m_primaryDir).absoluteFilePath(fileName);
    if (!QFile::exists(path)) {
        return {};
    }
    return QUrl::fromLocalFile(path).toString();
}

bool FxAssets::exists(const QString& fileName) const
{
    if (fileName.isEmpty()) {
        return false;
    }
    return QFile::exists(QDir(m_primaryDir).absoluteFilePath(fileName));
}

QString FxAssets::manifestUrl(const QString& category, const QString& baseName) const
{
    const QString key = category + QLatin1Char('/') + baseName;
    return m_manifest.value(key);
}

} // namespace Fognitix::UI
