#pragma once

#include <QString>

namespace Fognitix::Export {

class MP4Exporter {
public:
    static bool remuxToMp4(const QString& inputPath, const QString& outputPath, QString* errorOut);
};

} // namespace Fognitix::Export
