#pragma once

#include <QString>

#include <QJsonObject>

namespace Fognitix::State {
class AppState;
}

namespace Fognitix::Project {
class Project;
}

namespace Fognitix::Timeline {
class Timeline;
}

namespace Fognitix::AI {

class CommandExecutor {
public:
    static bool executeEnvelope(
        const QJsonObject& root,
        Fognitix::State::AppState& appState,
        Fognitix::Project::Project& project,
        Fognitix::Timeline::Timeline& timeline,
        QString* logOut,
        QString* errorOut);
};

} // namespace Fognitix::AI
