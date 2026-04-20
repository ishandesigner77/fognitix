#include <cassert>

#include <QTemporaryDir>

#include <QJsonArray>
#include <QJsonObject>

#include "core/ai/CommandExecutor.h"
#include "core/project/Project.h"
#include "core/state/AppState.h"
#include "core/timeline/Timeline.h"

int main()
{
    Fognitix::State::AppState state;
    Fognitix::Timeline::Timeline timeline;
    const QString tr = timeline.addVideoTrack(QStringLiteral("V1"));
    const QString clip = timeline.addClip(tr, QStringLiteral("m"), 0.0, 2.0);

    QTemporaryDir dir;
    assert(dir.isValid());
    const QString path = dir.path() + QStringLiteral("/ai.sqlite");
    auto project = Fognitix::Project::Project::createNew(path);
    assert(project);
    project->saveTimeline(timeline);

    QJsonObject cmd;
    cmd.insert(QStringLiteral("type"), QStringLiteral("apply_effect"));
    cmd.insert(QStringLiteral("target"), clip);
    cmd.insert(QStringLiteral("effect_id"), QStringLiteral("color_lut"));
    cmd.insert(QStringLiteral("parameters"), QJsonObject{{QStringLiteral("intensity"), 0.5}});

    QJsonArray cmds;
    cmds.append(cmd);

    QJsonObject envelope;
    QJsonObject inner;
    inner.insert(QStringLiteral("version"), QStringLiteral("1.0"));
    inner.insert(QStringLiteral("commands"), cmds);
    inner.insert(QStringLiteral("explanation"), QStringLiteral("unit test"));
    envelope.insert(QStringLiteral("ai_command"), inner);

    QString log;
    QString err;
    assert(Fognitix::AI::CommandExecutor::executeEnvelope(envelope, state, *project, timeline, &log, &err));

    auto again = timeline.findClip(clip);
    assert(again.has_value());
    assert(!again.value()->effectStack.isEmpty());
    return 0;
}
