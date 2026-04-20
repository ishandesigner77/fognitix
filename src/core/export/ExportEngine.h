#pragma once

#include <QString>

namespace Fognitix::Export {

class ExportEngine {
public:
    ExportEngine();

    bool enqueueRemuxMp4(const QString& inputPath, const QString& outputPath, QString* errorOut);

private:
    int m_jobCounter = 0;
};

} // namespace Fognitix::Export
