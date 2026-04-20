#include "Project.h"

#include <QtGlobal>
#include <QtLogging>

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QUuid>
#include <QVariantMap>

namespace Fognitix::Project {

namespace {

QString connectionNameForPath(const QString& path)
{
    return QStringLiteral("fognitix_") + QString::number(qHash(path), 16);
}

bool exec(QSqlDatabase& db, const QString& sql)
{
    QSqlQuery q(db);
    if (!q.exec(sql)) {
        qWarning() << "SQL failed:" << q.lastError().text() << sql;
        return false;
    }
    return true;
}

} // namespace

std::shared_ptr<Project> Project::createNew(const QString& filePath)
{
    if (QFile::exists(filePath)) {
        QFile::remove(filePath);
    }
    const QString name = connectionNameForPath(filePath);
    if (QSqlDatabase::contains(name)) {
        QSqlDatabase::removeDatabase(name);
    }
    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), name);
    db.setDatabaseName(filePath);
    if (!db.open()) {
        qWarning() << "open failed" << filePath << db.lastError().text();
        return nullptr;
    }
    if (!runMigrations(db)) {
        db.close();
        QSqlDatabase::removeDatabase(name);
        return nullptr;
    }
    return std::shared_ptr<Project>(new Project(filePath, db));
}

std::shared_ptr<Project> Project::openExisting(const QString& filePath)
{
    if (!QFile::exists(filePath)) {
        return nullptr;
    }
    const QString name = connectionNameForPath(filePath);
    if (QSqlDatabase::contains(name)) {
        QSqlDatabase::removeDatabase(name);
    }
    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), name);
    db.setDatabaseName(filePath);
    if (!db.open()) {
        return nullptr;
    }
    if (!runMigrations(db)) {
        db.close();
        QSqlDatabase::removeDatabase(name);
        return nullptr;
    }
    return std::shared_ptr<Project>(new Project(filePath, db));
}

Project::Project(QString path, QSqlDatabase db)
    : m_path(std::move(path))
    , m_db(std::move(db))
{
}

Project::~Project()
{
    const QString name = m_db.connectionName();
    m_db.close();
    QSqlDatabase::removeDatabase(name);
}

bool Project::runMigrations(QSqlDatabase& db)
{
    if (!exec(db, QStringLiteral("PRAGMA foreign_keys = ON;"))) {
        return false;
    }
    if (!exec(
            db,
            QStringLiteral(
                "CREATE TABLE IF NOT EXISTS schema_version (version INTEGER NOT NULL);"))) {
        return false;
    }
    QSqlQuery q(db);
    int version = 0;
    if (q.exec(QStringLiteral("SELECT version FROM schema_version LIMIT 1")) && q.next()) {
        version = q.value(0).toInt();
    }
    if (version < 1) {
        if (!exec(db,
                  QStringLiteral(
                      "CREATE TABLE IF NOT EXISTS timeline_state (id INTEGER PRIMARY KEY, json TEXT NOT NULL);"))) {
            return false;
        }
        if (!exec(db,
                  QStringLiteral(
                      "CREATE TABLE IF NOT EXISTS media_assets (id TEXT PRIMARY KEY, path TEXT NOT NULL, "
                      "proxy_path TEXT, duration REAL, width INTEGER, height INTEGER);"))) {
            return false;
        }
        if (!exec(db, QStringLiteral("INSERT OR REPLACE INTO schema_version(version) VALUES (1);"))) {
            return false;
        }
    }
    return true;
}

void Project::saveTimeline(const Fognitix::Timeline::Timeline& timeline)
{
    const QJsonDocument doc(timeline.toJson());
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("DELETE FROM timeline_state;"));
    q.exec();
    q.prepare(QStringLiteral("INSERT INTO timeline_state(id, json) VALUES (1, :json);"));
    q.bindValue(QStringLiteral(":json"), QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    if (!q.exec()) {
        qWarning() << "saveTimeline failed" << q.lastError().text();
    }
}

void Project::loadTimeline(Fognitix::Timeline::Timeline& timeline) const
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT json FROM timeline_state WHERE id=1 LIMIT 1;"));
    if (!q.exec() || !q.next()) {
        return;
    }
    const QByteArray raw = q.value(0).toString().toUtf8();
    const QJsonDocument doc = QJsonDocument::fromJson(raw);
    if (!doc.isObject()) {
        return;
    }
    timeline.loadFromJson(doc.object());
}

QJsonObject Project::snapshotForAi() const
{
    QJsonObject root;
    root.insert(QStringLiteral("project_path"), m_path);

    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT json FROM timeline_state WHERE id=1 LIMIT 1;"));
    QJsonObject timelineJson;
    if (q.exec() && q.next()) {
        const QByteArray raw = q.value(0).toString().toUtf8();
        const QJsonDocument doc = QJsonDocument::fromJson(raw);
        if (doc.isObject()) {
            timelineJson = doc.object();
        }
    }
    root.insert(QStringLiteral("timeline"), timelineJson);

    QJsonArray media;
    QSqlQuery mq(m_db);
    mq.exec(QStringLiteral("SELECT id, path, duration, width, height FROM media_assets;"));
    while (mq.next()) {
        QJsonObject m;
        m.insert(QStringLiteral("id"), mq.value(0).toString());
        m.insert(QStringLiteral("path"), mq.value(1).toString());
        m.insert(QStringLiteral("duration"), mq.value(2).toDouble());
        m.insert(QStringLiteral("width"), mq.value(3).toInt());
        m.insert(QStringLiteral("height"), mq.value(4).toInt());
        media.append(m);
    }
    root.insert(QStringLiteral("media"), media);
    return root;
}

QString Project::ensureMediaAsset(const QString& absolutePath, double durationSec, int width, int height)
{
    QFileInfo fi(absolutePath);
    const QString canon = fi.absoluteFilePath();

    QSqlQuery find(m_db);
    find.prepare(QStringLiteral("SELECT id FROM media_assets WHERE path = ? LIMIT 1;"));
    find.addBindValue(canon);
    if (find.exec() && find.next()) {
        const QString existing = find.value(0).toString();
        QSqlQuery up(m_db);
        up.prepare(QStringLiteral(
            "UPDATE media_assets SET duration = ?, width = ?, height = ? WHERE id = ?;"));
        up.addBindValue(durationSec);
        up.addBindValue(width);
        up.addBindValue(height);
        up.addBindValue(existing);
        up.exec();
        return existing;
    }

    const QString id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    QSqlQuery ins(m_db);
    ins.prepare(QStringLiteral(
        "INSERT INTO media_assets(id, path, proxy_path, duration, width, height) VALUES(?,?,?,?,?,?);"));
    ins.addBindValue(id);
    ins.addBindValue(canon);
    ins.addBindValue(QVariant());
    ins.addBindValue(durationSec);
    ins.addBindValue(width);
    ins.addBindValue(height);
    if (!ins.exec()) {
        qWarning() << "ensureMediaAsset insert failed" << ins.lastError().text();
        return {};
    }
    return id;
}

QString Project::mediaPathForId(const QString& mediaId) const
{
    if (mediaId.isEmpty()) {
        return {};
    }
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT path FROM media_assets WHERE id = ? LIMIT 1;"));
    q.addBindValue(mediaId);
    if (q.exec() && q.next()) {
        return q.value(0).toString();
    }
    return {};
}

QVariantList Project::mediaAssetsVariantList() const
{
    QVariantList out;
    QSqlQuery mq(m_db);
    mq.exec(QStringLiteral("SELECT id, path, duration, width, height FROM media_assets ORDER BY path;"));
    while (mq.next()) {
        QVariantMap m;
        const QString path = mq.value(1).toString();
        m.insert(QStringLiteral("id"), mq.value(0).toString());
        m.insert(QStringLiteral("path"), path);
        m.insert(QStringLiteral("name"), QFileInfo(path).fileName());
        m.insert(QStringLiteral("duration"), mq.value(2).toDouble());
        m.insert(QStringLiteral("width"), mq.value(3).toInt());
        m.insert(QStringLiteral("height"), mq.value(4).toInt());
        out.append(m);
    }
    return out;
}

} // namespace Fognitix::Project
