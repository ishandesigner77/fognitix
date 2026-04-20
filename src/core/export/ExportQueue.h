#pragma once

#include <deque>
#include <mutex>

#include <QString>

namespace Fognitix::Export {

struct ExportJob {
    QString inputPath;
    QString outputPath;
};

class ExportQueue {
public:
    void push(ExportJob job);
    bool pop(ExportJob* out);

private:
    std::mutex m_mutex;
    std::deque<ExportJob> m_jobs;
};

} // namespace Fognitix::Export
