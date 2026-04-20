#include "MainWindow.h"

#include "core/ai/CommandExecutor.h"
#include "core/ai/GroqClient.h"
#include "core/project/Project.h"
#include "core/state/AppState.h"
#include "core/state/SecureCredentialStore.h"
#include "core/timeline/Timeline.h"
#include "core/timeline/TimelineClip.h"
#include "core/timeline/EditOperations.h"
#include "core/engine/VideoEngine.h"
#include "core/codec/MediaProbe.h"
#include "core/export/MP4Exporter.h"

#include <QCoreApplication>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QMap>
#include <QUrl>
#include <cmath>
#include <limits>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QStandardPaths>
#include <QUuid>
#include <QVariantMap>
#include <QtGlobal>
#include <QTimer>
#include <QFileDialog>

#include <algorithm>

namespace Fognitix::UI {

namespace {

void ensureAeStyleDefaultTracks(Fognitix::Timeline::Timeline& timeline)
{
    using Fognitix::Timeline::TrackType;
    // Distinct but muted label-strip colors (visible yet editorial).
    const QString vidCol = QStringLiteral("#8b806c");  // warm graphite
    const QString audCol = QStringLiteral("#6ea078");  // muted sage green
    const QString txtCol = QStringLiteral("#9d8570");  // muted sand
    const QString adjCol = QStringLiteral("#b08a55");  // warm amber
    timeline.addTrack(QStringLiteral("V3"), TrackType::Video, 52, vidCol);
    timeline.addTrack(QStringLiteral("V2"), TrackType::Video, 52, vidCol);
    timeline.addTrack(QStringLiteral("V1"), TrackType::Video, 72, vidCol);
    timeline.addTrack(QStringLiteral("A1"), TrackType::Audio, 56, audCol);
    timeline.addTrack(QStringLiteral("A2"), TrackType::Audio, 52, audCol);
    timeline.addTrack(QStringLiteral("TEXT"), TrackType::Text, 48, txtCol);
    timeline.addTrack(QStringLiteral("ADJ"), TrackType::Adjustment, 44, adjCol);
}

QJsonObject defaultParametersFromDescriptor(const Fognitix::Effects::EffectDescriptor& d)
{
    QJsonObject o;
    for (const QJsonValue& pv : d.parameters) {
        const QJsonObject p = pv.toObject();
        const QString id = p.value(QStringLiteral("id")).toString();
        if (id.isEmpty()) {
            continue;
        }
        if (p.contains(QStringLiteral("default"))) {
            o.insert(id, p.value(QStringLiteral("default")));
        }
    }
    return o;
}

QVariantList parameterRowsForEffect(
    const Fognitix::Effects::EffectRegistry& reg,
    const QString& effectId,
    const QJsonObject& storedParams)
{
    QVariantList rows;
    const auto descOpt = reg.findById(effectId);
    if (descOpt.has_value()) {
        for (const QJsonValue& pv : descOpt->parameters) {
            const QJsonObject p = pv.toObject();
            const QString pid = p.value(QStringLiteral("id")).toString();
            if (pid.isEmpty()) {
                continue;
            }
            QVariantMap row;
            row.insert(QStringLiteral("key"), pid);
            row.insert(QStringLiteral("label"), p.value(QStringLiteral("name")).toString(pid));
            row.insert(QStringLiteral("min"), p.value(QStringLiteral("min")).toDouble(0.0));
            row.insert(QStringLiteral("max"), p.value(QStringLiteral("max")).toDouble(1.0));
            if (storedParams.contains(pid)) {
                row.insert(QStringLiteral("value"), storedParams.value(pid).toVariant());
            } else {
                row.insert(QStringLiteral("value"), p.value(QStringLiteral("default")).toVariant());
            }
            rows.append(row);
        }
    } else {
        for (auto it = storedParams.begin(); it != storedParams.end(); ++it) {
            QVariantMap row;
            row.insert(QStringLiteral("key"), it.key());
            row.insert(QStringLiteral("label"), it.key());
            row.insert(QStringLiteral("min"), 0.0);
            row.insert(QStringLiteral("max"), 1.0);
            row.insert(QStringLiteral("value"), it.value().toVariant());
            rows.append(row);
        }
    }
    return rows;
}

} // namespace

MainWindow::MainWindow(
    Fognitix::State::AppState& state,
    Fognitix::Effects::EffectRegistry& registry,
    Fognitix::AI::GroqClient& groq,
    std::shared_ptr<Fognitix::Project::Project> project,
    std::shared_ptr<Fognitix::Timeline::Timeline> timeline,
    Fognitix::Engine::VideoEngine* videoEngine,
    QObject* parent)
    : QObject(parent)
    , m_state(state)
    , m_registry(registry)
    , m_groq(groq)
    , m_project(std::move(project))
    , m_timeline(std::move(timeline))
    , m_videoEngine(videoEngine)
{
    loadSettings();
    QObject::connect(
        &m_state,
        &Fognitix::State::AppState::playheadSecondsChanged,
        this,
        &MainWindow::syncPreviewToPlayhead);
    QTimer::singleShot(0, this, [this]() { syncPreviewToPlayhead(); });
    loadFavoriteEffects();
    emit groqKeyChanged();

    QObject::connect(this, &MainWindow::timelineChanged, this, &MainWindow::clipEffectStackChanged);
    QObject::connect(this, &MainWindow::selectionStateChanged, this, &MainWindow::clipEffectStackChanged);
}

bool MainWindow::hasGroqApiKey() const
{
    return !m_groq.apiKey().isEmpty();
}

// ── workspace / preferences ────────────────────────────────────────────────

void MainWindow::setWorkspace(const QString& w)
{
    if (m_workspace == w) {
        return;
    }
    m_workspace = w;
    emit workspaceChanged();
    m_state.setStatusMessage(QStringLiteral("Workspace: ") + w);
    saveSettings();
}

void MainWindow::setPreviewQuality(const QString& q)
{
    if (m_previewQuality == q) {
        return;
    }
    m_previewQuality = q;
    emit previewQualityChanged();
    m_state.setStatusMessage(QStringLiteral("Preview: ") + q);
    saveSettings();
}

QString MainWindow::projectName() const
{
    if (!m_project) {
        return QStringLiteral("Untitled");
    }
    QFileInfo fi(m_project->filePath());
    QString base = fi.completeBaseName();
    if (base.endsWith(QStringLiteral(".fognitix"), Qt::CaseInsensitive)) {
        base.chop(QStringLiteral(".fognitix").size());
    }
    if (base.isEmpty()) {
        return QStringLiteral("Untitled");
    }
    return base;
}

QString MainWindow::projectPath() const
{
    return m_project ? m_project->filePath() : QString();
}

int MainWindow::trackCount() const
{
    return m_timeline ? static_cast<int>(m_timeline->tracks().size()) : 0;
}

int MainWindow::clipCount() const
{
    if (!m_timeline) return 0;
    int n = 0;
    for (const auto& t : m_timeline->tracks()) n += static_cast<int>(t.clips.size());
    return n;
}

QStringList MainWindow::effectIds() const
{
    QStringList ids;
    ids.reserve(static_cast<int>(m_registry.effects().size()));
    for (const auto& e : m_registry.effects()) {
        ids << e.id;
    }
    return ids;
}

QVariantList MainWindow::effectCatalogByCategory() const
{
    QMap<QString, QVariantList> buckets;
    for (const auto& e : m_registry.effects()) {
        const QString cat = e.category.isEmpty() ? QStringLiteral("General") : e.category;
        QVariantMap m;
        m.insert(QStringLiteral("id"), e.id);
        m.insert(QStringLiteral("name"), e.name);
        buckets[cat].append(m);
    }
    QVariantList out;
    out.reserve(buckets.size());
    for (auto it = buckets.constBegin(); it != buckets.constEnd(); ++it) {
        QVariantMap row;
        row.insert(QStringLiteral("category"), it.key());
        row.insert(QStringLiteral("effects"), it.value());
        out.append(row);
    }
    std::sort(out.begin(), out.end(), [](const QVariant& a, const QVariant& b) {
        return a.toMap().value(QStringLiteral("category")).toString().localeAwareCompare(
                   b.toMap().value(QStringLiteral("category")).toString())
            < 0;
    });
    return out;
}

int MainWindow::registryEffectCount() const
{
    return static_cast<int>(m_registry.effects().size());
}

void MainWindow::notifyEffectCatalogChanged()
{
    emit effectIdsChanged();
}

QVariantList MainWindow::timelineTracks() const
{
    QVariantList rows;
    if (!m_timeline) {
        return rows;
    }
    int idx = 0;
    for (const auto& tr : m_timeline->tracks()) {
        QVariantMap row;
        row.insert(QStringLiteral("trackId"), tr.id);
        row.insert(QStringLiteral("trackName"), tr.name);
        switch (tr.type) {
            case Fognitix::Timeline::TrackType::Audio:
                row.insert(QStringLiteral("trackType"), QStringLiteral("audio"));
                break;
            case Fognitix::Timeline::TrackType::Adjustment:
                row.insert(QStringLiteral("trackType"), QStringLiteral("adjustment"));
                break;
            case Fognitix::Timeline::TrackType::Text:
                row.insert(QStringLiteral("trackType"), QStringLiteral("text"));
                break;
            default:
                row.insert(QStringLiteral("trackType"), QStringLiteral("video"));
                break;
        }
        row.insert(QStringLiteral("trackIndex"), idx++);
        const int h = tr.heightPx > 0 ? tr.heightPx : 48;
        row.insert(QStringLiteral("heightPx"), std::clamp(h, 30, 200));
        row.insert(QStringLiteral("labelColor"), tr.labelColor);

        QVariantList clipsOut;
        for (const auto& c : tr.clips) {
            QVariantMap cm;
            cm.insert(QStringLiteral("clipId"), c.id);
            cm.insert(QStringLiteral("mediaId"), c.mediaId);
            cm.insert(QStringLiteral("start"), c.startOnTimeline);
            cm.insert(QStringLiteral("duration"), c.duration);
            cm.insert(QStringLiteral("sourceIn"), c.sourceInPoint);
            cm.insert(QStringLiteral("speed"), c.speed);
            QString path;
            if (m_project) {
                path = m_project->mediaPathForId(c.mediaId);
            }
            cm.insert(QStringLiteral("mediaPath"), path);
            const QString fn = QFileInfo(path).fileName();
            cm.insert(QStringLiteral("fileName"), fn.isEmpty() ? c.mediaId : fn);
            QString displayName;
            if (c.mediaId == QStringLiteral("fognitix.placeholder") || c.mediaId == QStringLiteral("placeholder_media")) {
                displayName = QStringLiteral("Import media");
            } else if (!fn.isEmpty()) {
                displayName = fn;
            } else if (!c.mediaId.isEmpty()) {
                displayName = c.mediaId;
            } else {
                displayName = QStringLiteral("Clip");
            }
            cm.insert(QStringLiteral("displayName"), displayName);
            cm.insert(QStringLiteral("effects"), c.effectStack.toVariantList());
            clipsOut.append(cm);
        }
        row.insert(QStringLiteral("clips"), clipsOut);
        rows.append(row);
    }
    return rows;
}

QVariantList MainWindow::effectChoicesFlat() const
{
    QVariantList rows;
    rows.reserve(static_cast<int>(m_registry.effects().size()));
    for (const auto& e : m_registry.effects()) {
        QVariantMap m;
        m.insert(QStringLiteral("id"), e.id);
        m.insert(QStringLiteral("name"), e.name);
        rows.append(m);
    }
    std::sort(rows.begin(), rows.end(), [](const QVariant& a, const QVariant& b) {
        return a.toMap().value(QStringLiteral("name")).toString().localeAwareCompare(
                   b.toMap().value(QStringLiteral("name")).toString())
            < 0;
    });
    return rows;
}

QVariantList MainWindow::selectedClipEffects() const
{
    QVariantList out;
    if (!m_timeline || m_selectedClipId.isEmpty()) {
        return out;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return out;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    const QJsonArray stack = clip->effectStack;
    for (const QJsonValue& v : stack) {
        const QJsonObject o = v.toObject();
        QVariantMap m;
        const QString effectId = o.value(QStringLiteral("effect_id")).toString();
        m.insert(QStringLiteral("instanceId"), o.value(QStringLiteral("instance_id")).toString());
        m.insert(QStringLiteral("effectId"), effectId);
        const auto descOpt = m_registry.findById(effectId);
        m.insert(QStringLiteral("displayName"),
                 descOpt.has_value() ? descOpt->name : effectId);
        const bool enabled = o.contains(QStringLiteral("enabled")) ? o.value(QStringLiteral("enabled")).toBool(true) : true;
        m.insert(QStringLiteral("enabled"), enabled);
        m.insert(QStringLiteral("expanded"), o.value(QStringLiteral("_ui_expanded")).toBool(false));
        const QJsonObject po = o.value(QStringLiteral("parameters")).toObject();
        m.insert(QStringLiteral("parameterRows"), parameterRowsForEffect(m_registry, effectId, po));
        out.append(m);
    }
    return out;
}

void MainWindow::addEffectToSelectedClip(const QString& effectId)
{
    if (!m_timeline || m_selectedClipId.isEmpty() || effectId.isEmpty()) {
        return;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return;
    }
    const auto descOpt = m_registry.findById(effectId);
    if (!descOpt.has_value()) {
        return;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    QJsonObject inst;
    inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
    inst.insert(QStringLiteral("effect_id"), effectId);
    inst.insert(QStringLiteral("enabled"), true);
    inst.insert(QStringLiteral("parameters"), defaultParametersFromDescriptor(*descOpt));
    inst.insert(QStringLiteral("keyframes"), QJsonArray());
    clip->effectStack.append(inst);
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    emit timelineChanged();
}

void MainWindow::removeEffectOnSelectedClip(int index)
{
    if (!m_timeline || m_selectedClipId.isEmpty()) {
        return;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    QJsonArray stack = clip->effectStack;
    if (index < 0 || index >= stack.size()) {
        return;
    }
    stack.removeAt(index);
    clip->effectStack = stack;
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    emit timelineChanged();
}

void MainWindow::setEffectEnabledOnSelectedClip(int index, bool enabled)
{
    if (!m_timeline || m_selectedClipId.isEmpty()) {
        return;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    QJsonArray stack = clip->effectStack;
    if (index < 0 || index >= stack.size()) {
        return;
    }
    QJsonObject o = stack.at(index).toObject();
    o.insert(QStringLiteral("enabled"), enabled);
    stack.removeAt(index);
    stack.insert(index, o);
    clip->effectStack = stack;
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    emit timelineChanged();
}

void MainWindow::setEffectExpandedOnSelectedClip(int index, bool expanded)
{
    if (!m_timeline || m_selectedClipId.isEmpty()) {
        return;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    QJsonArray stack = clip->effectStack;
    if (index < 0 || index >= stack.size()) {
        return;
    }
    QJsonObject o = stack.at(index).toObject();
    o.insert(QStringLiteral("_ui_expanded"), expanded);
    stack.removeAt(index);
    stack.insert(index, o);
    clip->effectStack = stack;
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    emit timelineChanged();
}

void MainWindow::setSelectedClipEffectParameter(int effectIndex, const QString& key, double value)
{
    if (!m_timeline || m_selectedClipId.isEmpty() || key.isEmpty()) {
        return;
    }
    auto clipOpt = m_timeline->findClip(m_selectedClipId);
    if (!clipOpt.has_value()) {
        return;
    }
    Fognitix::Timeline::TimelineClip* clip = clipOpt.value();
    QJsonArray stack = clip->effectStack;
    if (effectIndex < 0 || effectIndex >= stack.size()) {
        return;
    }
    QJsonObject o = stack.at(effectIndex).toObject();
    QJsonObject params = o.value(QStringLiteral("parameters")).toObject();
    params.insert(key, value);
    o.insert(QStringLiteral("parameters"), params);
    stack.removeAt(effectIndex);
    stack.insert(effectIndex, o);
    clip->effectStack = stack;
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    emit timelineChanged();
}

QVariantList MainWindow::mediaPool() const
{
    if (!m_project) {
        return {};
    }
    return m_project->mediaAssetsVariantList();
}

double MainWindow::compositionDuration() const
{
    if (!m_timeline) {
        return 30.0;
    }
    double end = 1.0;
    for (const auto& tr : m_timeline->tracks()) {
        for (const auto& c : tr.clips) {
            end = std::max(end, c.startOnTimeline + c.duration);
        }
    }
    return std::max(end, 5.0);
}

QString MainWindow::mediaPathForId(const QString& mediaId) const
{
    if (!m_project) {
        return {};
    }
    return m_project->mediaPathForId(mediaId);
}

void MainWindow::setUiToolName(const QString& name)
{
    if (m_uiToolName == name) {
        return;
    }
    m_uiToolName = name;
    emit uiToolNameChanged();
}

void MainWindow::runCommandSearch(const QString& query)
{
    const QString q = query.trimmed().toLower();
    if (q.isEmpty())
        return;
    if (q.contains(QStringLiteral("import"))) {
        emit requestOpenDialog(QStringLiteral("import"));
        m_state.setStatusMessage(QStringLiteral("Command: Import"));
    } else if (q.contains(QStringLiteral("export"))) {
        emit requestOpenDialog(QStringLiteral("export"));
        m_state.setStatusMessage(QStringLiteral("Command: Export"));
    } else if (q.contains(QStringLiteral("settings"))) {
        emit requestOpenDialog(QStringLiteral("settings"));
        m_state.setStatusMessage(QStringLiteral("Command: Settings"));
    } else if (q.contains(QStringLiteral("ai"))) {
        emit aiSuggestions(QStringList{QStringLiteral("Open AI Agent"), QStringLiteral("Auto Edit"), QStringLiteral("Generate Captions")});
        m_state.setStatusMessage(QStringLiteral("Command: AI"));
    } else {
        m_state.setStatusMessage(QStringLiteral("Search: ") + query);
    }
}

QStringList MainWindow::recentProjectPaths() const
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    return s.value(QStringLiteral("ui/recentProjects")).toStringList();
}

void MainWindow::pushRecentProjectPath(const QString& path)
{
    if (path.isEmpty()) {
        return;
    }
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    QStringList list = s.value(QStringLiteral("ui/recentProjects")).toStringList();
    list.removeAll(path);
    list.prepend(path);
    while (list.size() > 10) {
        list.removeLast();
    }
    s.setValue(QStringLiteral("ui/recentProjects"), list);
    s.setValue(QStringLiteral("ui/lastProjectPath"), path);
    emit recentProjectsChanged();
}

void MainWindow::openLastRecentProject()
{
    const QString p = lastRecentProjectPath();
    if (!p.isEmpty()) {
        openProject(p);
    }
}

QString MainWindow::lastRecentProjectPath() const
{
    const auto list = recentProjectPaths();
    return list.isEmpty() ? QString{} : list.front();
}

QString MainWindow::recentProjectPathAt(int index) const
{
    const auto list = recentProjectPaths();
    if (index < 0 || index >= list.size()) {
        return {};
    }
    return list.at(index);
}

void MainWindow::loadFavoriteEffects()
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    m_favoriteEffectIds = s.value(QStringLiteral("ui/favoriteEffects")).toStringList();
}

void MainWindow::saveFavoriteEffects()
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    s.setValue(QStringLiteral("ui/favoriteEffects"), m_favoriteEffectIds);
}

void MainWindow::toggleFavoriteEffect(const QString& effectId)
{
    if (effectId.isEmpty()) {
        return;
    }
    if (m_favoriteEffectIds.contains(effectId)) {
        m_favoriteEffectIds.removeAll(effectId);
    } else {
        m_favoriteEffectIds.append(effectId);
    }
    saveFavoriteEffects();
    emit favoriteEffectIdsChanged();
}

void MainWindow::loadSettings()
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    m_workspace = s.value(QStringLiteral("ui/workspace"), QStringLiteral("Standard")).toString();
    m_previewQuality = s.value(QStringLiteral("ui/previewQuality"), QStringLiteral("Full")).toString();
    {
        const QString pal = s.value(QStringLiteral("ui/palette"), QStringLiteral("dark")).toString().toLower();
        m_uiPalette = (pal == QStringLiteral("light")) ? QStringLiteral("light") : QStringLiteral("dark");
    }
    m_compositionFps = s.value(QStringLiteral("ui/compositionFps"), 30.0).toDouble();
    if (m_compositionFps < 1.0 || m_compositionFps > 120.0) {
        m_compositionFps = 30.0;
    }
}

void MainWindow::saveSettings()
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    s.setValue(QStringLiteral("ui/workspace"), m_workspace);
    s.setValue(QStringLiteral("ui/previewQuality"), m_previewQuality);
    s.setValue(QStringLiteral("ui/palette"), m_uiPalette);
    s.setValue(QStringLiteral("ui/compositionFps"), m_compositionFps);
}

void MainWindow::setUiPalette(const QString& p)
{
    const QString n = p.trimmed().toLower() == QStringLiteral("light") ? QStringLiteral("light")
                                                                       : QStringLiteral("dark");
    if (m_uiPalette == n) {
        return;
    }
    m_uiPalette = n;
    emit uiPaletteChanged();
    saveSettings();
}

void MainWindow::setCompositionFps(double fps)
{
    if (!std::isfinite(fps)) {
        return;
    }
    double n = std::clamp(fps, 1.0, 120.0);
    if (std::abs(m_compositionFps - n) < 1e-6) {
        return;
    }
    m_compositionFps = n;
    emit compositionFpsChanged();
    saveSettings();
}

QVariantMap MainWindow::testGroqConnection()
{
    QString err;
    const bool ok = m_groq.testConnection(&err);
    QVariantMap m;
    m.insert(QStringLiteral("ok"), ok);
    m.insert(QStringLiteral("message"), ok ? QStringLiteral("SUCCESS") : err);
    return m;
}

// ── undo/redo ──────────────────────────────────────────────────────────────

void MainWindow::pushUndo()
{
    if (!m_timeline) return;
    const QJsonObject snap = m_timeline->toJson();
    m_undoStack.push_back(QJsonDocument(snap).toJson(QJsonDocument::Compact));
    if (m_undoStack.size() > 64) {
        m_undoStack.erase(m_undoStack.begin());
    }
    m_redoStack.clear();
    emit undoStateChanged();
}

void MainWindow::undo()
{
    if (m_undoStack.empty() || !m_timeline) {
        m_state.setStatusMessage(QStringLiteral("Nothing to undo"));
        return;
    }
    const QJsonObject cur = m_timeline->toJson();
    m_redoStack.push_back(QJsonDocument(cur).toJson(QJsonDocument::Compact));
    const QByteArray b = m_undoStack.back();
    m_undoStack.pop_back();
    m_timeline->loadFromJson(QJsonDocument::fromJson(b).object());
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Undo"));
    emit undoStateChanged();
    emit timelineChanged();
    syncPreviewToPlayhead();
}

void MainWindow::redo()
{
    if (m_redoStack.empty() || !m_timeline) {
        m_state.setStatusMessage(QStringLiteral("Nothing to redo"));
        return;
    }
    const QJsonObject cur = m_timeline->toJson();
    m_undoStack.push_back(QJsonDocument(cur).toJson(QJsonDocument::Compact));
    const QByteArray b = m_redoStack.back();
    m_redoStack.pop_back();
    m_timeline->loadFromJson(QJsonDocument::fromJson(b).object());
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Redo"));
    emit undoStateChanged();
    emit timelineChanged();
    syncPreviewToPlayhead();
}

// ── AI ─────────────────────────────────────────────────────────────────────

void MainWindow::setGroqApiKey(const QString& key)
{
    Fognitix::State::SecureCredentialStore::writeGroqApiKey(key);
    m_groq.setApiKey(key);
    m_state.setStatusMessage(QStringLiteral("Groq API key saved"));
    emit aiLogAppended(QStringLiteral("API key saved."));
    emit groqKeyChanged();
}

void MainWindow::submitAiPrompt(const QString& prompt)
{
    if (!m_project || !m_timeline) {
        const QString msg = QStringLiteral("No project loaded.");
        m_state.setStatusMessage(msg);
        emit aiLogAppended(msg);
        return;
    }
    if (m_aiBusy) {
        return;
    }
    m_aiBusy = true;
    emit aiBusyChanged();
    m_aiProgress = 0.05;
    emit aiProgressChanged();

    pushUndo();

    QJsonObject user;
    user.insert(QStringLiteral("prompt"), prompt);
    user.insert(QStringLiteral("project"), m_project->snapshotForAi());

    QJsonArray availEffects;
    for (const auto& e : m_registry.effects()) {
        availEffects.append(e.id);
    }
    user.insert(QStringLiteral("available_effects"), availEffects);

    const QString system = QStringLiteral(
        "You are Fognitix AI, a pro video editor copilot (think After Effects + DaVinci + Premiere). "
        "You can drive the editor by replying with JSON ONLY, no prose, matching this schema:\n"
        "{\"ai_command\":{\"version\":\"1.0\",\"commands\":[...],\"explanation\":\"short friendly summary\"}}\n"
        "\n"
        "Available command types:\n"
        "- apply_effect: {type, target: clip_id or \"all\", effect_id, parameters:{}, keyframes:[]}\n"
        "- edit_timeline: {type, operation: cut|add_transition|ripple_delete|slip|slide, target_clip, at_time, transition_id?, duration?}\n"
        "- modify_parameter: {type, target_clip, effect_id, parameter_id, value}\n"
        "- add_keyframe: {type, target_clip, parameter_id, time, value, interpolation?}\n"
        "- add_text_layer: {type, text, start, duration, font?, size?, color?}\n"
        "- add_shape_layer: {type, shape: rect|ellipse|star, start, duration, color?}\n"
        "- add_adjustment_layer: {type, start, duration}\n"
        "- color_grade: {type, target: clip_id or \"all\", lift?, gamma?, gain?, temperature?, tint?, saturation?}\n"
        "- speed_change: {type, target_clip, speed, optical_flow?}\n"
        "- add_3d_layer: {type, target_clip, camera?: {position, rotation}}\n"
        "- remove_silences: {type, threshold_db?}\n"
        "- beat_sync: {type, audio_track?}\n"
        "- generate_captions: {type, language?}\n"
        "- export: {type, preset, path?}\n"
        "\n"
        "Keep explanation under 2 sentences, friendly and concrete.");

    m_aiProgress = 0.2;
    emit aiProgressChanged();
    QString err;
    const QJsonObject modelJson = m_groq.completeJson(system, user, &err);
    if (!err.isEmpty()) {
        m_state.setStatusMessage(err);
        emit aiLogAppended(QStringLiteral("AI error: ") + err);
        m_aiProgress = 0.0;
        emit aiProgressChanged();
        m_aiBusy = false;
        emit aiBusyChanged();
        return;
    }

    m_aiProgress = 0.55;
    emit aiProgressChanged();
    QString log;
    if (!Fognitix::AI::CommandExecutor::executeEnvelope(modelJson, m_state, *m_project, *m_timeline, &log, &err)) {
        m_state.setStatusMessage(err);
        emit aiLogAppended(QStringLiteral("[WARN] ") + err);
        m_aiProgress = 0.0;
        emit aiProgressChanged();
        m_aiBusy = false;
        emit aiBusyChanged();
        return;
    }
    emit aiLogAppended(log.isEmpty() ? QStringLiteral("Done.") : log);
    m_state.timelineObservable().setValue(m_timeline);
    emit timelineChanged();
    syncPreviewToPlayhead();

    QStringList suggestions;
    const QJsonObject env = modelJson.contains(QStringLiteral("ai_command"))
                                ? modelJson.value(QStringLiteral("ai_command")).toObject()
                                : modelJson;
    const QString exp = env.value(QStringLiteral("explanation")).toString();
    if (!exp.isEmpty()) {
        const auto parts = exp.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
        for (const QString& part : parts) {
            const QString t = part.trimmed();
            if (t.length() > 3 && t.length() < 120) {
                suggestions.append(t);
            }
        }
        if (suggestions.isEmpty()) {
            suggestions.append(exp.left(80));
        }
    }
    if (suggestions.isEmpty()) {
        suggestions << QStringLiteral("Apply a subtle vignette")
                    << QStringLiteral("Normalize loudness on dialogue")
                    << QStringLiteral("Add crossfade between clips");
    }
    emit aiSuggestions(suggestions);

    m_aiProgress = 1.0;
    emit aiProgressChanged();
    m_aiBusy = false;
    emit aiBusyChanged();
    m_aiProgress = 0.0;
    emit aiProgressChanged();
}

void MainWindow::selectTimelineClip(const QString& trackId, const QString& clipId)
{
    if (m_selectedTrackId == trackId && m_selectedClipId == clipId) {
        return;
    }
    m_selectedTrackId = trackId;
    m_selectedClipId = clipId;
    emit selectionStateChanged();
    syncPreviewToPlayhead();
}

void MainWindow::clearTimelineSelection()
{
    if (m_selectedTrackId.isEmpty() && m_selectedClipId.isEmpty()) {
        return;
    }
    m_selectedTrackId.clear();
    m_selectedClipId.clear();
    emit selectionStateChanged();
}

void MainWindow::refreshPreview()
{
    syncPreviewToPlayhead();
}

// ── project lifecycle ──────────────────────────────────────────────────────

void MainWindow::newProject()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    const QString path = dir + QStringLiteral("/untitled_") +
                         QUuid::createUuid().toString(QUuid::WithoutBraces).left(8) +
                         QStringLiteral(".fognitix.sqlite");
    createNewProject(path);
}

void MainWindow::createNewProject(const QString& sqlitePath, bool defaultTrackLayout)
{
    QString path = sqlitePath.trimmed();
    if (path.isEmpty()) {
        m_state.setStatusMessage(QStringLiteral("Choose a file location for the new project"));
        return;
    }
    const QFileInfo fi(path);
    if (fi.suffix().isEmpty()) {
        path += QStringLiteral(".fognitix.sqlite");
    }
    auto p = Fognitix::Project::Project::createNew(path);
    if (!p) {
        m_state.setStatusMessage(QStringLiteral("Failed to create project"));
        return;
    }
    m_project = std::move(p);
    m_timeline = std::make_shared<Fognitix::Timeline::Timeline>();
    if (defaultTrackLayout) {
        ensureAeStyleDefaultTracks(*m_timeline);
    } else {
        (void)m_timeline->addVideoTrack(QStringLiteral("V1"));
    }
    m_project->saveTimeline(*m_timeline);
    m_state.projectObservable().setValue(m_project);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setPlayheadSeconds(0.0);
    m_state.setStatusMessage(QStringLiteral("New project — ") + projectName());
    m_undoStack.clear();
    m_redoStack.clear();
    emit projectNameChanged();
    emit timelineChanged();
    emit mediaPoolChanged();
    emit undoStateChanged();
    pushRecentProjectPath(path);
    clearTimelineSelection();
    syncPreviewToPlayhead();
}

void MainWindow::openProject(const QString& path)
{
    auto p = Fognitix::Project::Project::openExisting(path);
    if (!p) {
        m_state.setStatusMessage(QStringLiteral("Failed to open: ") + path);
        return;
    }
    m_project = std::move(p);
    m_timeline = std::make_shared<Fognitix::Timeline::Timeline>();
    m_project->loadTimeline(*m_timeline);
    m_state.projectObservable().setValue(m_project);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setPlayheadSeconds(0.0);
    m_state.setStatusMessage(QStringLiteral("Opened ") + projectName());
    m_undoStack.clear();
    m_redoStack.clear();
    emit projectNameChanged();
    emit timelineChanged();
    emit mediaPoolChanged();
    emit undoStateChanged();
    pushRecentProjectPath(path);
    clearTimelineSelection();
    syncPreviewToPlayhead();
}

void MainWindow::saveProject()
{
    if (m_project && m_timeline) {
        m_project->saveTimeline(*m_timeline);
        m_state.setStatusMessage(QStringLiteral("Saved ") + projectName());
    }
}

void MainWindow::saveProjectAs(const QString& path)
{
    if (!m_timeline) return;
    auto p = Fognitix::Project::Project::createNew(path);
    if (!p) {
        m_state.setStatusMessage(QStringLiteral("Save As failed"));
        return;
    }
    m_project = std::move(p);
    m_project->saveTimeline(*m_timeline);
    m_state.projectObservable().setValue(m_project);
    m_state.setStatusMessage(QStringLiteral("Saved as ") + projectName());
    emit projectNameChanged();
    emit mediaPoolChanged();
    syncPreviewToPlayhead();
}

void MainWindow::openImportMediaDialog()
{
    const QString filter = QStringLiteral(
        "All supported (*.mp4 *.mov *.avi *.mkv *.wmv *.mxf *.webm *.wav *.mp3 *.aac *.flac *.ogg *.m4a *.png *.jpg *.jpeg *.jpe *.tif *.tiff *.tga *.exr *.bmp);;"
        "Video (*.mp4 *.mov *.avi *.mkv *.wmv *.mxf *.webm);;"
        "Audio (*.wav *.mp3 *.aac *.flac *.ogg *.m4a);;"
        "Images (*.png *.jpg *.jpeg *.jpe *.tif *.tiff *.tga *.exr *.bmp);;"
        "All files (*.*)");
    const QStringList paths = QFileDialog::getOpenFileNames(
        nullptr,
        tr("Import media"),
        QString(),
        filter);
    importMediaPaths(paths);
}

void MainWindow::importMedia(const QString& path)
{
    importMediaPaths(path.isEmpty() ? QStringList{} : QStringList{path});
}

void MainWindow::importMediaPaths(const QStringList& paths)
{
    if (paths.isEmpty()) {
        return;
    }
    if (!m_project || !m_timeline) {
        m_state.setStatusMessage(QStringLiteral("No project loaded"));
        return;
    }

    bool undoPushed = false;
    auto ensureUndo = [this, &undoPushed]() {
        if (!undoPushed) {
            pushUndo();
            undoPushed = true;
        }
    };

    QString firstVideoPath;
    double firstVideoStart = 0.0;
    int imported = 0;
    int failed = 0;

    double vCursor = m_state.playheadSeconds();
    double aCursor = m_state.playheadSeconds();

    auto pickVideoTrack = [this]() -> QString {
        for (const auto& tr : m_timeline->tracks()) {
            if (tr.type == Fognitix::Timeline::TrackType::Video && tr.name == QStringLiteral("V1")) {
                return tr.id;
            }
        }
        for (const auto& tr : m_timeline->tracks()) {
            if (tr.type == Fognitix::Timeline::TrackType::Video) {
                return tr.id;
            }
        }
        return m_timeline->addVideoTrack(QStringLiteral("V1"));
    };

    auto pickAudioTrack = [this]() -> QString {
        for (const auto& tr : m_timeline->tracks()) {
            if (tr.type == Fognitix::Timeline::TrackType::Audio && tr.name == QStringLiteral("A1")) {
                return tr.id;
            }
        }
        for (const auto& tr : m_timeline->tracks()) {
            if (tr.type == Fognitix::Timeline::TrackType::Audio) {
                return tr.id;
            }
        }
        return m_timeline->addAudioTrack(QStringLiteral("A1"));
    };

    for (const QString& path : paths) {
        const QString abs = QFileInfo(path).absoluteFilePath();
        Fognitix::Codec::MediaProbeResult probe;
        QString perr;
        if (!Fognitix::Codec::probeMediaFile(abs, probe, &perr)) {
            ++failed;
            continue;
        }

        double clipDur = probe.durationSec > 0.05 ? probe.durationSec : 5.0;
        const QString mediaId = m_project->ensureMediaAsset(abs, probe.durationSec, probe.width, probe.height);
        if (mediaId.isEmpty()) {
            ++failed;
            continue;
        }

        ensureUndo();

        if (probe.hasVideo) {
            const QString videoTrackId = pickVideoTrack();
            m_timeline->addClip(videoTrackId, mediaId, vCursor, clipDur);
            if (firstVideoPath.isEmpty()) {
                firstVideoPath = abs;
                firstVideoStart = vCursor;
            }
            vCursor += clipDur;
            ++imported;
        } else if (probe.hasAudio) {
            const QString audioTrackId = pickAudioTrack();
            m_timeline->addClip(audioTrackId, mediaId, aCursor, clipDur);
            aCursor += clipDur;
            ++imported;
        } else {
            ++failed;
        }
    }

    if (undoPushed) {
        m_project->saveTimeline(*m_timeline);
        m_state.timelineObservable().setValue(m_timeline);
        emit timelineChanged();
    }
    emit mediaPoolChanged();

    if (!firstVideoPath.isEmpty() && m_videoEngine) {
        QString err;
        if (m_videoEngine->openMedia(firstVideoPath, &err)) {
            const double localT = std::max(0.0, m_state.playheadSeconds() - firstVideoStart);
            m_videoEngine->refreshPreviewAt(localT);
        } else {
            m_state.setStatusMessage(err);
        }
    } else {
        syncPreviewToPlayhead();
    }

    if (imported > 0) {
        QString msg = tr("Imported %1 file(s)").arg(imported);
        if (failed > 0) {
            msg += tr(" (%1 skipped)").arg(failed);
        }
        m_state.setStatusMessage(msg);
    } else if (failed > 0) {
        m_state.setStatusMessage(tr("Import failed for selected file(s)"));
    }
}

void MainWindow::exportMedia(const QString& path, const QString& preset)
{
    if (!m_timeline || !m_project || path.trimmed().isEmpty()) {
        m_state.setStatusMessage(QStringLiteral("Export failed: invalid project or output path"));
        return;
    }

    QString sourceMediaPath;
    for (const auto& tr : m_timeline->tracks()) {
        if (tr.type != Fognitix::Timeline::TrackType::Video)
            continue;
        for (const auto& c : tr.clips) {
            const QString p = m_project->mediaPathForId(c.mediaId);
            if (!p.isEmpty()) {
                sourceMediaPath = p;
                break;
            }
        }
        if (!sourceMediaPath.isEmpty())
            break;
    }
    if (sourceMediaPath.isEmpty()) {
        m_state.setStatusMessage(QStringLiteral("Export failed: no video media on timeline"));
        return;
    }

    m_renderProgress = 0.2;
    emit renderProgressChanged();
    QString err;
    const bool ok = Fognitix::Export::MP4Exporter::remuxToMp4(sourceMediaPath, path, &err);
    m_renderProgress = ok ? 1.0 : 0.0;
    emit renderProgressChanged();
    if (ok) {
        m_state.setStatusMessage(QStringLiteral("Export complete: ") + path);
        emit aiLogAppended(QStringLiteral("Export complete (") + preset + QStringLiteral("): ") + path);
    } else {
        m_state.setStatusMessage(QStringLiteral("Export failed: ") + err);
        emit aiLogAppended(QStringLiteral("Export failed: ") + err);
    }
}

// ── edit ops ───────────────────────────────────────────────────────────────

void MainWindow::cutSelection()
{
    pushUndo();
    m_state.setStatusMessage(QStringLiteral("Cut"));
}

void MainWindow::copySelection()
{
    m_state.setStatusMessage(QStringLiteral("Copy"));
}

void MainWindow::paste()
{
    pushUndo();
    m_state.setStatusMessage(QStringLiteral("Paste"));
}

void MainWindow::deleteSelection()
{
    pushUndo();
    m_state.setStatusMessage(QStringLiteral("Delete"));
}

void MainWindow::splitAtPlayhead()
{
    if (!m_timeline) return;
    const double t = m_state.playheadSeconds();
    pushUndo();
    int cuts = 0;
    for (auto& tr : m_timeline->tracks()) {
        for (auto& clip : tr.clips) {
            if (t > clip.startOnTimeline && t < clip.startOnTimeline + clip.duration) {
                if (Fognitix::Timeline::EditOperations::cutClipAtTime(*m_timeline, clip.id, t)) {
                    ++cuts;
                }
            }
        }
    }
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Split ×") + QString::number(cuts));
    emit timelineChanged();
}

// ── timeline ops ───────────────────────────────────────────────────────────

QString MainWindow::addVideoTrack(const QString& name)
{
    if (!m_timeline) return {};
    pushUndo();
    const QString id = m_timeline->addVideoTrack(name);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    emit timelineChanged();
    return id;
}

QString MainWindow::addAudioTrack(const QString& name)
{
    if (!m_timeline) return {};
    pushUndo();
    const QString id = m_timeline->addAudioTrack(name);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    emit timelineChanged();
    return id;
}

QString MainWindow::addTextLayer(const QString& text)
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    for (const auto& t : m_timeline->tracks()) {
        if (t.type == Fognitix::Timeline::TrackType::Text && t.name == QStringLiteral("TEXT")) {
            trackId = t.id;
            break;
        }
    }
    if (trackId.isEmpty()) {
        trackId = m_timeline->addTrack(
            QStringLiteral("TEXT"), Fognitix::Timeline::TrackType::Text, 48, QStringLiteral("#9d8570"));
    }
    const double start = m_state.playheadSeconds();
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("text:") + text, start, 3.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Text: ") + text);
    emit timelineChanged();
    return clipId;
}

QString MainWindow::addShapeLayer(const QString& shape)
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    if (!m_timeline->tracks().empty()) trackId = m_timeline->tracks().front().id;
    else trackId = m_timeline->addVideoTrack(QStringLiteral("V1"));
    const double start = m_state.playheadSeconds();
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("shape:") + shape, start, 3.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Shape: ") + shape);
    emit timelineChanged();
    return clipId;
}

QString MainWindow::addAdjustmentLayer()
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    for (const auto& t : m_timeline->tracks()) {
        if (t.type == Fognitix::Timeline::TrackType::Adjustment && t.name == QStringLiteral("ADJ")) {
            trackId = t.id;
            break;
        }
    }
    if (trackId.isEmpty()) {
        trackId = m_timeline->addTrack(
            QStringLiteral("ADJ"), Fognitix::Timeline::TrackType::Adjustment, 36, QStringLiteral("#3d2800"));
    }
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("adjustment"), 0.0, 10.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Adjustment layer added"));
    emit timelineChanged();
    return clipId;
}

QString MainWindow::addSolidLayer(const QString& name)
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    for (const auto& t : m_timeline->tracks()) {
        if (t.type == Fognitix::Timeline::TrackType::Video) {
            trackId = t.id;
            break;
        }
    }
    if (trackId.isEmpty())
        trackId = m_timeline->addVideoTrack(QStringLiteral("V1"));
    const QString label = name.trimmed().isEmpty() ? QStringLiteral("Solid") : name.trimmed();
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("solid:") + label, m_state.playheadSeconds(), 3.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Solid layer added"));
    emit timelineChanged();
    return clipId;
}

QString MainWindow::addCameraLayer(const QString& name)
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    for (const auto& t : m_timeline->tracks()) {
        if (t.type == Fognitix::Timeline::TrackType::Video) {
            trackId = t.id;
            break;
        }
    }
    if (trackId.isEmpty())
        trackId = m_timeline->addVideoTrack(QStringLiteral("V1"));
    const QString label = name.trimmed().isEmpty() ? QStringLiteral("Camera") : name.trimmed();
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("camera:") + label, m_state.playheadSeconds(), 5.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Camera layer added"));
    emit timelineChanged();
    return clipId;
}

QString MainWindow::addLightLayer(const QString& name)
{
    if (!m_timeline) return {};
    pushUndo();
    QString trackId;
    for (const auto& t : m_timeline->tracks()) {
        if (t.type == Fognitix::Timeline::TrackType::Video) {
            trackId = t.id;
            break;
        }
    }
    if (trackId.isEmpty())
        trackId = m_timeline->addVideoTrack(QStringLiteral("V1"));
    const QString label = name.trimmed().isEmpty() ? QStringLiteral("Light") : name.trimmed();
    const QString clipId = m_timeline->addClip(trackId, QStringLiteral("light:") + label, m_state.playheadSeconds(), 5.0);
    if (m_project) m_project->saveTimeline(*m_timeline);
    m_state.timelineObservable().setValue(m_timeline);
    m_state.setStatusMessage(QStringLiteral("Light layer added"));
    emit timelineChanged();
    return clipId;
}

// ── playback ───────────────────────────────────────────────────────────────

void MainWindow::togglePlayback()
{
    m_state.setIsPlaying(!m_state.isPlaying());
}

void MainWindow::stepFrame(int frames)
{
    const double fps = 30.0;
    m_state.setPlayheadSeconds(std::max(0.0, m_state.playheadSeconds() + frames / fps));
}

void MainWindow::gotoStart() { m_state.setPlayheadSeconds(0.0); }
void MainWindow::gotoEnd()
{
    if (!m_timeline) return;
    double end = 0.0;
    for (const auto& t : m_timeline->tracks())
        for (const auto& c : t.clips)
            end = std::max(end, c.startOnTimeline + c.duration);
    m_state.setPlayheadSeconds(end);
}

void MainWindow::play()  { m_state.setIsPlaying(true);  }
void MainWindow::pause() { m_state.setIsPlaying(false); }
void MainWindow::stop()  { m_state.setIsPlaying(false); m_state.setPlaybackRate(1.0); gotoStart(); }
void MainWindow::seek(double seconds) { m_state.setPlayheadSeconds(std::max(0.0, seconds)); }

void MainWindow::nudgePlaybackRate(int dir)
{
    double r = m_state.playbackRate();
    if (dir > 0) {
        if (r <= 0)      r = 1.0;
        else if (r < 1)  r = 1.0;
        else             r = std::min(8.0, r * 2.0);
    } else if (dir < 0) {
        if (r >= 0 && r <= 1.0) r = -1.0;
        else if (r < 0) r = std::max(-8.0, r * 2.0);
        else r = -1.0;
    }
    m_state.setPlaybackRate(r);
    m_state.setIsPlaying(true);
}

void MainWindow::setInPointAtPlayhead()  { m_state.setInPoint(m_state.playheadSeconds()); }
void MainWindow::setOutPointAtPlayhead() { m_state.setOutPoint(m_state.playheadSeconds()); }
void MainWindow::gotoInPoint()  { if (m_state.hasInPoint())  m_state.setPlayheadSeconds(m_state.inPoint()); }
void MainWindow::gotoOutPoint() { if (m_state.hasOutPoint()) m_state.setPlayheadSeconds(m_state.outPoint()); }

void MainWindow::addMarkerAtPlayhead(const QString& name)
{
    m_state.addMarker(m_state.playheadSeconds(), name.isEmpty() ? QStringLiteral("Marker") : name);
}

void MainWindow::gotoNextMarker()
{
    double t = m_state.nextMarkerTime(m_state.playheadSeconds());
    if (t >= 0.0) m_state.setPlayheadSeconds(t);
}

void MainWindow::gotoPrevMarker()
{
    double t = m_state.prevMarkerTime(m_state.playheadSeconds());
    if (t >= 0.0) m_state.setPlayheadSeconds(t);
}

void MainWindow::gotoNextEdit()
{
    if (!m_timeline) return;
    double cur = m_state.playheadSeconds();
    double best = std::numeric_limits<double>::infinity();
    for (const auto& t : m_timeline->tracks()) {
        for (const auto& c : t.clips) {
            double s = c.startOnTimeline;
            double e = c.startOnTimeline + c.duration;
            if (s > cur + 1e-6 && s < best) best = s;
            if (e > cur + 1e-6 && e < best) best = e;
        }
    }
    if (std::isfinite(best)) m_state.setPlayheadSeconds(best);
}

void MainWindow::gotoPrevEdit()
{
    if (!m_timeline) return;
    double cur = m_state.playheadSeconds();
    double best = -1.0;
    for (const auto& t : m_timeline->tracks()) {
        for (const auto& c : t.clips) {
            double s = c.startOnTimeline;
            double e = c.startOnTimeline + c.duration;
            if (s < cur - 1e-6 && s > best) best = s;
            if (e < cur - 1e-6 && e > best) best = e;
        }
    }
    if (best >= 0.0) m_state.setPlayheadSeconds(best);
}

void MainWindow::rippleDelete()    { deleteSelection(); emit timelineChanged(); }
void MainWindow::duplicateSelection() { copySelection(); paste(); }
void MainWindow::selectAll()       { /* implemented in QML layer as needed */ }
void MainWindow::deselectAll()     { clearTimelineSelection(); }

// ── PNG asset resolver ─────────────────────────────────────────────────────

void MainWindow::ensurePngIndex() const
{
    if (m_pngIndexLoaded) return;
    m_pngIndexLoaded = true;
    const QStringList roots {
        QCoreApplication::applicationDirPath() + QStringLiteral("/PNG"),
        QCoreApplication::applicationDirPath() + QStringLiteral("/assets/PNG"),
        QCoreApplication::applicationDirPath() + QStringLiteral("/../PNG"),
    };
    for (const auto& r : roots) {
        QDir d(r);
        if (!d.exists()) continue;
        QDirIterator it(d.absolutePath(),
                        QStringList() << QStringLiteral("*.png"),
                        QDir::Files,
                        QDirIterator::Subdirectories);
        while (it.hasNext()) {
            m_pngAssetIndex.append(it.next());
            if (m_pngAssetIndex.size() > 8000) break;
        }
        if (!m_pngAssetIndex.isEmpty()) break;
    }
}

QString MainWindow::pngAssetUrl(const QString& name) const
{
    ensurePngIndex();
    if (name.isEmpty() || m_pngAssetIndex.isEmpty()) return {};
    const QString needle = name.toLower();
    // exact basename match first
    for (const auto& p : m_pngAssetIndex) {
        if (QFileInfo(p).completeBaseName().compare(needle, Qt::CaseInsensitive) == 0)
            return QUrl::fromLocalFile(p).toString();
    }
    // substring
    for (const auto& p : m_pngAssetIndex) {
        if (p.toLower().contains(needle))
            return QUrl::fromLocalFile(p).toString();
    }
    return {};
}

QStringList MainWindow::listPngAssets(const QString& filter) const
{
    ensurePngIndex();
    if (filter.isEmpty()) return m_pngAssetIndex;
    QStringList out;
    const QString f = filter.toLower();
    for (const auto& p : m_pngAssetIndex) {
        if (p.toLower().contains(f)) out.append(p);
    }
    return out;
}

// ── workspace helpers ──────────────────────────────────────────────────────

void MainWindow::toggleWorkspace(const QString& name) { setWorkspace(name); }

QVariantMap MainWindow::workspaceLayout(const QString& name) const
{
    QVariantMap m;
    if (name == QStringLiteral("Color")) {
        m[QStringLiteral("leftTab")] = 0;
        m[QStringLiteral("rightTab")] = 1;
        m[QStringLiteral("showScopes")] = true;
    } else if (name == QStringLiteral("Editing")) {
        m[QStringLiteral("leftTab")] = 0;
        m[QStringLiteral("rightTab")] = 0;
    } else if (name == QStringLiteral("VFX") || name == QStringLiteral("Motion Tracking")) {
        m[QStringLiteral("leftTab")] = 2;
        m[QStringLiteral("rightTab")] = 0;
    } else {
        m[QStringLiteral("leftTab")] = 0;
        m[QStringLiteral("rightTab")] = 3;  // AI tab default
    }
    return m;
}

QVariantMap MainWindow::loadEditorLayout() const
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    QVariantMap m;
    m.insert(QStringLiteral("leftInner"), s.value(QStringLiteral("editor/leftInner"), 320).toInt());
    m.insert(QStringLiteral("midW"), s.value(QStringLiteral("editor/midW"), 240).toInt());
    m.insert(QStringLiteral("rightW"), s.value(QStringLiteral("editor/rightW"), 320).toInt());
    m.insert(QStringLiteral("showLeftBody"), s.value(QStringLiteral("editor/showLeftBody"), true).toBool());
    m.insert(QStringLiteral("showMid"), s.value(QStringLiteral("editor/showMid"), false).toBool());
    m.insert(QStringLiteral("showRight"), s.value(QStringLiteral("editor/showRight"), true).toBool());
    m.insert(QStringLiteral("previewRatio"), s.value(QStringLiteral("editor/previewRatio"), 0.62).toDouble());
    return m;
}

void MainWindow::saveEditorLayout(const QVariantMap& m)
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    for (auto it = m.constBegin(); it != m.constEnd(); ++it) {
        s.setValue(QStringLiteral("editor/") + it.key(), it.value());
    }
}

void MainWindow::resetEditorLayout()
{
    QSettings s(QStringLiteral("Fognitix"), QStringLiteral("Fognitix"));
    s.remove(QStringLiteral("editor"));
    m_state.setStatusMessage(QStringLiteral("Window layout reset"));
}

void MainWindow::syncPreviewToPlayhead()
{
    if (!m_timeline || !m_project || !m_videoEngine) {
        return;
    }
    const double ph = m_state.playheadSeconds();
    for (const auto& tr : m_timeline->tracks()) {
        if (tr.type != Fognitix::Timeline::TrackType::Video) {
            continue;
        }
        for (const auto& c : tr.clips) {
            if (ph < c.startOnTimeline || ph >= c.startOnTimeline + c.duration) {
                continue;
            }
            const QString path = m_project->mediaPathForId(c.mediaId);
            if (path.isEmpty()) {
                continue;
            }
            QString err;
            if (m_videoEngine->currentMediaPath() != path) {
                if (!m_videoEngine->openMedia(path, &err)) {
                    m_state.setStatusMessage(err);
                    return;
                }
            }
            const double localT = c.sourceInPoint + (ph - c.startOnTimeline) * c.speed;
            m_videoEngine->refreshPreviewAt(std::max(0.0, localT));
            return;
        }
    }
    m_videoEngine->closeMedia();
}

void MainWindow::setTrackHeightPx(const QString& trackId, int heightPx)
{
    if (!m_timeline || trackId.isEmpty()) {
        return;
    }
    const int h = std::clamp(heightPx, 30, 200);
    for (auto& tr : m_timeline->tracks()) {
        if (tr.id == trackId) {
            tr.heightPx = h;
            break;
        }
    }
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    m_state.timelineObservable().setValue(m_timeline);
    emit timelineChanged();
}

void MainWindow::resetTrackHeightPx(const QString& trackId)
{
    setTrackHeightPx(trackId, 48);
}

void MainWindow::setTrackLabelColor(const QString& trackId, const QString& hexColor)
{
    if (!m_timeline || trackId.isEmpty()) {
        return;
    }
    for (auto& tr : m_timeline->tracks()) {
        if (tr.id == trackId) {
            tr.labelColor = hexColor;
            break;
        }
    }
    if (m_project) {
        m_project->saveTimeline(*m_timeline);
    }
    m_state.timelineObservable().setValue(m_timeline);
    emit timelineChanged();
}

void MainWindow::undoLastAiCommand()
{
    undo();
}

} // namespace Fognitix::UI
