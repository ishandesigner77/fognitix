#pragma once

#include <memory>

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "core/effects/EffectRegistry.h"
#include "core/engine/AudioEngine.h"
#include "core/engine/VideoEngine.h"
#include "core/project/Project.h"
#include "core/state/AppState.h"
#include "core/timeline/Timeline.h"
#include "ui/MainWindow.h"
#include "ui/BootProgress.h"

namespace Fognitix::AI {
class GroqClient;
}

namespace Fognitix::UI {
class EffectCatalogModel;
class EffectCatalogFilterModel;
class ThumbnailImageProvider;
class WaveformImageProvider;
class SystemMetrics;
class FxAssets;
} // namespace Fognitix::UI

namespace Fognitix {

class Application {
public:
    explicit Application(QGuiApplication& app);
    ~Application();
    int exec();

private:
    void ensureDefaultProject();

    QGuiApplication& m_app;
    std::unique_ptr<Fognitix::State::AppState> m_appState;
    QQmlApplicationEngine m_engine;

    std::shared_ptr<Fognitix::Timeline::Timeline> m_timeline;
    std::shared_ptr<Fognitix::Project::Project> m_project;

    Fognitix::Effects::EffectRegistry m_effectRegistry;
    Fognitix::Engine::AudioEngine m_audioEngine;
    std::unique_ptr<Fognitix::Engine::VideoEngine> m_videoEngine;
    std::unique_ptr<Fognitix::AI::GroqClient> m_groqClient;
    std::unique_ptr<Fognitix::UI::MainWindow> m_mainWindow;
    std::unique_ptr<Fognitix::UI::EffectCatalogModel> m_effectCatalog;
    std::unique_ptr<Fognitix::UI::EffectCatalogFilterModel> m_effectFilter;

    Fognitix::UI::ThumbnailImageProvider* m_thumbProvider = nullptr;
    Fognitix::UI::WaveformImageProvider* m_waveProvider = nullptr;
    std::unique_ptr<Fognitix::UI::SystemMetrics> m_systemMetrics;
    std::unique_ptr<Fognitix::UI::FxAssets> m_fxAssets;
    std::unique_ptr<Fognitix::UI::BootProgress> m_bootProgress;
};

} // namespace Fognitix
