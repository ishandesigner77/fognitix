#pragma once

#include <memory>

#include <QString>
#include <QSqlDatabase>
#include <QVariant>

#include "core/timeline/Timeline.h"

namespace Fognitix::Project {

class Project {
public:
    static std::shared_ptr<Project> createNew(const QString& filePath);
    static std::shared_ptr<Project> openExisting(const QString& filePath);

    ~Project();

    const QString& filePath() const noexcept { return m_path; }
    QSqlDatabase& database() noexcept { return m_db; }

    void saveTimeline(const Fognitix::Timeline::Timeline& timeline);
    void loadTimeline(Fognitix::Timeline::Timeline& timeline) const;

    QJsonObject snapshotForAi() const;

    QString ensureMediaAsset(const QString& absolutePath, double durationSec, int width, int height);
    QString mediaPathForId(const QString& mediaId) const;
    QVariantList mediaAssetsVariantList() const;

private:
    explicit Project(QString path, QSqlDatabase db);

    static bool runMigrations(QSqlDatabase& db);

    QString m_path;
    QSqlDatabase m_db;
};

} // namespace Fognitix::Project
