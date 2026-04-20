#include <cassert>

#include <QTemporaryDir>
#include <QTemporaryFile>

#include <QString>

#include "core/export/MP4Exporter.h"

int main()
{
    QString err;
    QTemporaryDir dir;
    assert(dir.isValid());
    QTemporaryFile in(dir.path() + QStringLiteral("/in.mp4"));
    assert(in.open());
    const QString outPath = dir.path() + QStringLiteral("/out.mp4");
    assert(!Fognitix::Export::MP4Exporter::remuxToMp4(in.fileName(), outPath, &err));
    return 0;
}
