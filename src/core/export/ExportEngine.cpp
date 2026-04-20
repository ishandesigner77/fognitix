#include "ExportEngine.h"

#include "MP4Exporter.h"

namespace Fognitix::Export {

ExportEngine::ExportEngine() = default;

bool ExportEngine::enqueueRemuxMp4(const QString& inputPath, const QString& outputPath, QString* errorOut)
{
    ++m_jobCounter;
    return MP4Exporter::remuxToMp4(inputPath, outputPath, errorOut);
}

} // namespace Fognitix::Export
