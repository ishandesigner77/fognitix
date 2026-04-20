#pragma once

#include <memory>

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>

#include "core/effects/EffectRegistry.h"

namespace Fognitix::AI {
class GroqClient;
}

namespace Fognitix::Project {
class Project;
}

namespace Fognitix::Timeline {
class Timeline;
}

namespace Fognitix::State {
class AppState;
}

namespace Fognitix::Engine {
class VideoEngine;
}

namespace Fognitix::UI {

class MainWindow : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString workspace READ workspace WRITE setWorkspace NOTIFY workspaceChanged)
    Q_PROPERTY(QString projectName READ projectName NOTIFY projectNameChanged)
    Q_PROPERTY(QString projectPath READ projectPath NOTIFY projectNameChanged)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY undoStateChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY undoStateChanged)
    Q_PROPERTY(int trackCount READ trackCount NOTIFY timelineChanged)
    Q_PROPERTY(int clipCount READ clipCount NOTIFY timelineChanged)
    Q_PROPERTY(QString previewQuality READ previewQuality WRITE setPreviewQuality NOTIFY previewQualityChanged)
    Q_PROPERTY(bool aiBusy READ aiBusy NOTIFY aiBusyChanged)
    Q_PROPERTY(double aiProgress READ aiProgress NOTIFY aiProgressChanged)
    Q_PROPERTY(QString selectedClipId READ selectedClipId NOTIFY selectionStateChanged)
    Q_PROPERTY(QString selectedTrackId READ selectedTrackId NOTIFY selectionStateChanged)
    Q_PROPERTY(QStringList effectIds READ effectIds NOTIFY effectIdsChanged)
    Q_PROPERTY(QVariantList effectCatalogByCategory READ effectCatalogByCategory NOTIFY effectIdsChanged)
    Q_PROPERTY(int registryEffectCount READ registryEffectCount NOTIFY effectIdsChanged)
    Q_PROPERTY(QVariantList timelineTracks READ timelineTracks NOTIFY timelineChanged)
    Q_PROPERTY(QVariantList selectedClipEffects READ selectedClipEffects NOTIFY clipEffectStackChanged)
    Q_PROPERTY(QVariantList effectChoicesFlat READ effectChoicesFlat NOTIFY effectIdsChanged)
    Q_PROPERTY(QVariantList mediaPool READ mediaPool NOTIFY mediaPoolChanged)
    Q_PROPERTY(double compositionDuration READ compositionDuration NOTIFY timelineChanged)
    Q_PROPERTY(double renderProgress READ renderProgress NOTIFY renderProgressChanged)
    Q_PROPERTY(QString uiToolName READ uiToolName NOTIFY uiToolNameChanged)
    Q_PROPERTY(int recentProjectCount READ recentProjectCount NOTIFY recentProjectsChanged)
    Q_PROPERTY(QStringList favoriteEffectIds READ favoriteEffectIds NOTIFY favoriteEffectIdsChanged)
    Q_PROPERTY(QString uiPalette READ uiPalette WRITE setUiPalette NOTIFY uiPaletteChanged)
    Q_PROPERTY(bool hasGroqApiKey READ hasGroqApiKey NOTIFY groqKeyChanged)
    Q_PROPERTY(QStringList recentProjects READ recentProjects NOTIFY recentProjectsChanged)
    Q_PROPERTY(double compositionFps READ compositionFps WRITE setCompositionFps NOTIFY compositionFpsChanged)

public:
    MainWindow(
        Fognitix::State::AppState& state,
        Fognitix::Effects::EffectRegistry& registry,
        Fognitix::AI::GroqClient& groq,
        std::shared_ptr<Fognitix::Project::Project> project,
        std::shared_ptr<Fognitix::Timeline::Timeline> timeline,
        Fognitix::Engine::VideoEngine* videoEngine,
        QObject* parent = nullptr);

    QString workspace() const { return m_workspace; }
    void setWorkspace(const QString& w);

    QString projectName() const;
    QString projectPath() const;

    bool canUndo() const { return !m_undoStack.empty(); }
    bool canRedo() const { return !m_redoStack.empty(); }

    int trackCount() const;
    int clipCount() const;

    QString previewQuality() const { return m_previewQuality; }
    void setPreviewQuality(const QString& q);

    bool aiBusy() const { return m_aiBusy; }
    double aiProgress() const { return m_aiProgress; }
    QString selectedClipId() const { return m_selectedClipId; }
    QString selectedTrackId() const { return m_selectedTrackId; }

    QStringList effectIds() const;
    QVariantList effectCatalogByCategory() const;
    int registryEffectCount() const;

    Q_INVOKABLE QString mediaPathForId(const QString& mediaId) const;

    QVariantList timelineTracks() const;
    QVariantList selectedClipEffects() const;
    QVariantList effectChoicesFlat() const;
    QVariantList mediaPool() const;
    double compositionDuration() const;
    double renderProgress() const { return m_renderProgress; }

    QString uiToolName() const { return m_uiToolName; }
    int recentProjectCount() const { return recentProjectPaths().size(); }
    QStringList favoriteEffectIds() const { return m_favoriteEffectIds; }

    QString uiPalette() const { return m_uiPalette; }
    void setUiPalette(const QString& p);
    bool hasGroqApiKey() const;

    QStringList recentProjects() const { return recentProjectPaths(); }
    double compositionFps() const { return m_compositionFps; }
    void setCompositionFps(double fps);

    Q_INVOKABLE void setUiToolName(const QString& name);
    Q_INVOKABLE void runCommandSearch(const QString& query);
    Q_INVOKABLE void toggleFavoriteEffect(const QString& effectId);
    Q_INVOKABLE void openLastRecentProject();
    Q_INVOKABLE QString lastRecentProjectPath() const;
    Q_INVOKABLE QString recentProjectPathAt(int index) const;

    // AI
    Q_INVOKABLE void setGroqApiKey(const QString& key);
    Q_INVOKABLE QVariantMap testGroqConnection();
    Q_INVOKABLE void submitAiPrompt(const QString& prompt);
    Q_INVOKABLE void selectTimelineClip(const QString& trackId, const QString& clipId);
    Q_INVOKABLE void clearTimelineSelection();
    Q_INVOKABLE void addEffectToSelectedClip(const QString& effectId);
    Q_INVOKABLE void removeEffectOnSelectedClip(int index);
    Q_INVOKABLE void setEffectEnabledOnSelectedClip(int index, bool enabled);
    Q_INVOKABLE void setEffectExpandedOnSelectedClip(int index, bool expanded);
    Q_INVOKABLE void setSelectedClipEffectParameter(int effectIndex, const QString& key, double value);
    Q_INVOKABLE void refreshPreview();

    // Project
    Q_INVOKABLE void newProject();
    Q_INVOKABLE void createNewProject(const QString& sqlitePath, bool defaultTrackLayout = true);
    void notifyEffectCatalogChanged();
    Q_INVOKABLE void openProject(const QString& path);
    Q_INVOKABLE void saveProject();
    Q_INVOKABLE void saveProjectAs(const QString& path);
    Q_INVOKABLE void importMedia(const QString& path);
    Q_INVOKABLE void importMediaPaths(const QStringList& paths);
    Q_INVOKABLE void openImportMediaDialog();
    Q_INVOKABLE void exportMedia(const QString& path, const QString& preset);

    // Edit
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void cutSelection();
    Q_INVOKABLE void copySelection();
    Q_INVOKABLE void paste();
    Q_INVOKABLE void deleteSelection();
    Q_INVOKABLE void splitAtPlayhead();

    // Timeline ops
    Q_INVOKABLE QString addVideoTrack(const QString& name);
    Q_INVOKABLE QString addAudioTrack(const QString& name);
    Q_INVOKABLE QString addTextLayer(const QString& text);
    Q_INVOKABLE QString addShapeLayer(const QString& shape);
    Q_INVOKABLE QString addAdjustmentLayer();
    Q_INVOKABLE QString addSolidLayer(const QString& name = QStringLiteral("Solid"));
    Q_INVOKABLE QString addCameraLayer(const QString& name = QStringLiteral("Camera"));
    Q_INVOKABLE QString addLightLayer(const QString& name = QStringLiteral("Light"));

    // Playback
    Q_INVOKABLE void togglePlayback();
    Q_INVOKABLE void stepFrame(int frames);
    Q_INVOKABLE void gotoStart();
    Q_INVOKABLE void gotoEnd();
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void seek(double seconds);
    Q_INVOKABLE void nudgePlaybackRate(int dir); // J/L multi-press: dir=-1 or +1
    Q_INVOKABLE void setInPointAtPlayhead();
    Q_INVOKABLE void setOutPointAtPlayhead();
    Q_INVOKABLE void gotoInPoint();
    Q_INVOKABLE void gotoOutPoint();
    Q_INVOKABLE void addMarkerAtPlayhead(const QString& name = {});
    Q_INVOKABLE void gotoNextMarker();
    Q_INVOKABLE void gotoPrevMarker();
    Q_INVOKABLE void gotoNextEdit();
    Q_INVOKABLE void gotoPrevEdit();
    Q_INVOKABLE void rippleDelete();
    Q_INVOKABLE void duplicateSelection();
    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void deselectAll();

    // PNG asset resolver — maps a logical name to an asset URL
    Q_INVOKABLE QString pngAssetUrl(const QString& name) const;
    Q_INVOKABLE QStringList listPngAssets(const QString& filter = {}) const;

    Q_INVOKABLE void setTrackHeightPx(const QString& trackId, int heightPx);
    Q_INVOKABLE void resetTrackHeightPx(const QString& trackId);
    Q_INVOKABLE void setTrackLabelColor(const QString& trackId, const QString& hexColor);
    Q_INVOKABLE void undoLastAiCommand();

    // UI
    Q_INVOKABLE void toggleWorkspace(const QString& name);
    Q_INVOKABLE QVariantMap workspaceLayout(const QString& name) const;

    /// Persisted editor dock geometry (QSettings group editor/)
    Q_INVOKABLE QVariantMap loadEditorLayout() const;
    Q_INVOKABLE void saveEditorLayout(const QVariantMap& m);
    Q_INVOKABLE void resetEditorLayout();

signals:
    void aiLogAppended(const QString& line);
    void aiUserMessage(const QString& text);
    void aiBusyChanged();
    void aiProgressChanged();
    void selectionStateChanged();
    void workspaceChanged();
    void projectNameChanged();
    void undoStateChanged();
    void timelineChanged();
    void previewQualityChanged();
    void effectIdsChanged();
    void mediaPoolChanged();
    void renderProgressChanged();
    void aiSuggestions(const QStringList& suggestions);
    void uiToolNameChanged();
    void recentProjectsChanged();
    void favoriteEffectIdsChanged();
    void uiPaletteChanged();
    void groqKeyChanged();
    void compositionFpsChanged();
    void clipEffectStackChanged();
    void requestOpenDialog(const QString& what);
    void requestSaveDialog(const QString& what);

private:
    void syncPreviewToPlayhead();
    QStringList recentProjectPaths() const;
    void pushRecentProjectPath(const QString& path);
    void loadFavoriteEffects();
    void saveFavoriteEffects();

    QString m_uiToolName = QStringLiteral("Selection");
    QStringList m_favoriteEffectIds;
    void pushUndo();
    void loadSettings();
    void saveSettings();

    Fognitix::State::AppState& m_state;
    Fognitix::Effects::EffectRegistry& m_registry;
    Fognitix::AI::GroqClient& m_groq;
    std::shared_ptr<Fognitix::Project::Project> m_project;
    std::shared_ptr<Fognitix::Timeline::Timeline> m_timeline;
    Fognitix::Engine::VideoEngine* m_videoEngine = nullptr;

    QString m_uiPalette = QStringLiteral("dark");
    double m_compositionFps = 30.0;
    QString m_workspace = QStringLiteral("Standard");
    QString m_previewQuality = QStringLiteral("Full");
    bool m_aiBusy = false;
    double m_aiProgress = 0.0;
    double m_renderProgress = 0.0;
    QString m_selectedClipId;
    QString m_selectedTrackId;

    std::vector<QByteArray> m_undoStack;
    std::vector<QByteArray> m_redoStack;
    QByteArray m_clipboard;

    mutable QStringList m_pngAssetIndex;
    mutable bool m_pngIndexLoaded = false;
    void ensurePngIndex() const;
};

} // namespace Fognitix::UI
