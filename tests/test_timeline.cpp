#include <cassert>
#include <cstdlib>

#include <QTemporaryDir>
#include <QtGlobal>

#include "core/project/Project.h"
#include "core/timeline/EditOperations.h"
#include "core/timeline/Timeline.h"

int main()
{
    Fognitix::Timeline::Timeline timeline;
    const QString tr = timeline.addVideoTrack(QStringLiteral("V1"));
    assert(!tr.isEmpty());
    const QString clip = timeline.addClip(tr, QStringLiteral("m1"), 0.0, 10.0);
    assert(!clip.isEmpty());

    QString err;
    assert(Fognitix::Timeline::EditOperations::cutClipAtTime(timeline, clip, 3.0));

    const auto found = timeline.findClip(clip);
    assert(found.has_value());
    assert(std::abs(found.value()->duration - 3.0) < 1e-6);

    QTemporaryDir dir;
    assert(dir.isValid());
    const QString path = dir.path() + QStringLiteral("/t.sqlite");
    auto project = Fognitix::Project::Project::createNew(path);
    assert(project);
    project->saveTimeline(timeline);

    Fognitix::Timeline::Timeline loaded;
    project->loadTimeline(loaded);
    assert(!loaded.tracks().empty());
    return 0;
}
