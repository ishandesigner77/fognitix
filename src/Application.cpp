#include "Application.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QUrl>
#include <QStandardPaths>
#include <QFile>
#include <QObject>
#include <QQmlContext>
#include <QTextStream>

#include "core/ai/GroqClient.h"
#include "core/timeline/Timeline.h"
#include "core/state/SecureCredentialStore.h"
#include "ui/EffectCatalogFilterModel.h"
#include "ui/EffectCatalogModel.h"
#include "ui/PreviewImageProvider.h"
#include "ui/ThumbnailImageProvider.h"
#include "ui/WaveformImageProvider.h"
#include "ui/SystemMetrics.h"
#include "ui/FxAssets.h"
#include "ui/BootProgress.h"

static QFile* s_logFile = nullptr;
static void messageHandler(QtMsgType type, const QMessageLogContext&, const QString& msg)
{
    if (s_logFile && s_logFile->isOpen()) {
        QTextStream ts(s_logFile);
        switch (type) {
        case QtDebugMsg:    ts << "[D] "; break;
        case QtWarningMsg:  ts << "[W] "; break;
        case QtCriticalMsg: ts << "[C] "; break;
        case QtFatalMsg:    ts << "[F] "; break;
        default: break;
        }
        ts << msg << "\n";
        s_logFile->flush();
    }
}

namespace Fognitix {

Application::Application(QGuiApplication& app)
    : m_app(app)
{
    {
        const QString logDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
        QDir().mkpath(logDir);
        const QString logPath = QDir(logDir).absoluteFilePath(QStringLiteral("fognitix_launch.log"));
        s_logFile = new QFile(logPath);
        if (!s_logFile->open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
            delete s_logFile;
            s_logFile = new QFile(QDir::tempPath() + QStringLiteral("/fognitix_launch.log"));
            s_logFile->open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);
        }
    }

    qInstallMessageHandler(messageHandler);
    qDebug() << "Log file:" << (s_logFile ? s_logFile->fileName() : QStringLiteral("(none)"));
    qDebug() << "Application starting...";

    m_bootProgress = std::make_unique<Fognitix::UI::BootProgress>();
    m_bootProgress->setPhase(QStringLiteral("Initializing core…"), 0.04);

    m_appState = std::make_unique<Fognitix::State::AppState>();
    m_timeline = std::make_shared<Fognitix::Timeline::Timeline>();
    m_groqClient = std::make_unique<Fognitix::AI::GroqClient>();

    m_bootProgress->setPhase(QStringLiteral("Opening project database…"), 0.12);
    ensureDefaultProject();

    m_videoEngine = std::make_unique<Fognitix::Engine::VideoEngine>(*m_appState);
    m_mainWindow = std::make_unique<Fognitix::UI::MainWindow>(
        *m_appState, m_effectRegistry, *m_groqClient, m_project, m_timeline, m_videoEngine.get());
    m_bootProgress->setPhase(QStringLiteral("Preparing workspace…"), 0.28);

    QString regErr;
    if (!m_effectRegistry.loadBundled(&regErr)) {
        m_appState->setStatusMessage(regErr);
    }
    m_bootProgress->setPhase(
        regErr.isEmpty() ? QStringLiteral("Loading effects registry…") : QStringLiteral("Effects registry warning…"),
        0.42);

    m_effectCatalog = std::make_unique<Fognitix::UI::EffectCatalogModel>();
    m_effectCatalog->rebuild(m_effectRegistry.effects());
    m_mainWindow->notifyEffectCatalogChanged();
    m_effectFilter = std::make_unique<Fognitix::UI::EffectCatalogFilterModel>();
    m_effectFilter->setSourceModel(m_effectCatalog.get());
    m_effectFilter->setFavoriteIds(m_mainWindow->favoriteEffectIds());
    QObject::connect(m_mainWindow.get(), &Fognitix::UI::MainWindow::favoriteEffectIdsChanged, m_effectFilter.get(),
        [this]() { m_effectFilter->setFavoriteIds(m_mainWindow->favoriteEffectIds()); });

    m_appState->timelineObservable().setValue(m_timeline);
    m_appState->projectObservable().setValue(m_project);

    QString audioErr;
    m_audioEngine.start(&audioErr);
    if (!audioErr.isEmpty()) {
        m_appState->setStatusMessage(audioErr);
    }
    m_bootProgress->setPhase(
        audioErr.isEmpty() ? QStringLiteral("Starting audio engine…") : QStringLiteral("Audio engine limited…"),
        0.58);

    m_groqClient->setApiKey(Fognitix::State::SecureCredentialStore::readGroqApiKey());

    m_engine.addImageProvider(
        QStringLiteral("fognitixPreview"),
        new Fognitix::UI::PreviewImageProvider(m_appState.get()));

    m_thumbProvider = new Fognitix::UI::ThumbnailImageProvider([mw = m_mainWindow.get()](const QString& mediaId) {
        return mw ? mw->mediaPathForId(mediaId) : QString{};
    });
    m_engine.addImageProvider(QStringLiteral("fognitixThumb"), m_thumbProvider);

    m_waveProvider = new Fognitix::UI::WaveformImageProvider([mw = m_mainWindow.get()](const QString& mediaId) {
        return mw ? mw->mediaPathForId(mediaId) : QString{};
    });
    m_engine.addImageProvider(QStringLiteral("fognitixWave"), m_waveProvider);

    m_systemMetrics = std::make_unique<Fognitix::UI::SystemMetrics>();
    m_fxAssets = std::make_unique<Fognitix::UI::FxAssets>(&m_app);
    m_bootProgress->setPhase(QStringLiteral("Loading UI assets…"), 0.72);

    m_engine.rootContext()->setContextProperty(QStringLiteral("appState"), m_appState.get());
    m_engine.rootContext()->setContextProperty(QStringLiteral("mainWindow"), m_mainWindow.get());
    m_engine.rootContext()->setContextProperty(QStringLiteral("bootProgress"), m_bootProgress.get());
    m_engine.rootContext()->setContextProperty(QStringLiteral("effectsFiltered"), m_effectFilter.get());
    m_engine.rootContext()->setContextProperty(QStringLiteral("systemMetrics"), m_systemMetrics.get());
    m_engine.rootContext()->setContextProperty(QStringLiteral("fxAssets"), m_fxAssets.get());

    {
        QString docs = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        docs = QDir(docs).absoluteFilePath(QStringLiteral("FognitixProjects"));
        QDir().mkpath(docs);
        m_engine.rootContext()->setContextProperty(
            QStringLiteral("fognitixDefaultProjectDirUrl"), QUrl::fromLocalFile(docs).toString());
    }

    qDebug() << "Loading QML module...";
    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() {
        qCritical() << "QML object creation FAILED - check ~/fognitix_launch.log";
        QCoreApplication::exit(1);
    });
    m_engine.loadFromModule(QStringLiteral("Fognitix"), QStringLiteral("MainWindow"));
    m_bootProgress->finalize(QStringLiteral("Ready."));
}

Application::~Application() = default;

void Application::ensureDefaultProject()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    const QString path = dir + QStringLiteral("/Untitled_Project.fognitix.sqlite");
    // Migrate legacy default project path once
    const QString legacyPath = dir + QStringLiteral("/default.fognitix.sqlite");
    if (!QFile::exists(path) && QFile::exists(legacyPath)) {
        QFile::rename(legacyPath, path);
    }
    m_project = Fognitix::Project::Project::createNew(path);
    if (!m_project) {
        m_project = Fognitix::Project::Project::openExisting(path);
    }
    if (!m_project) {
        return;
    }
    m_project->loadTimeline(*m_timeline);
    if (m_timeline->tracks().empty()) {
        using Fognitix::Timeline::TrackType;
        m_timeline->addTrack(QStringLiteral("V3"), TrackType::Video, 48, QStringLiteral("#1e3a6e"));
        m_timeline->addTrack(QStringLiteral("V2"), TrackType::Video, 48, QStringLiteral("#1e3a6e"));
        m_timeline->addTrack(QStringLiteral("V1"), TrackType::Video, 72, QStringLiteral("#1e3a6e"));
        m_timeline->addTrack(QStringLiteral("A1"), TrackType::Audio, 56, QStringLiteral("#0f3d1f"));
        m_timeline->addTrack(QStringLiteral("A2"), TrackType::Audio, 48, QStringLiteral("#0f3d1f"));
        m_timeline->addTrack(QStringLiteral("TEXT"), TrackType::Text, 48, QStringLiteral("#3d1a5c"));
        m_timeline->addTrack(QStringLiteral("ADJ"), TrackType::Adjustment, 36, QStringLiteral("#3d2800"));
        m_project->saveTimeline(*m_timeline);
    }
}

int Application::exec()
{
    return m_app.exec();
}

} // namespace Fognitix
