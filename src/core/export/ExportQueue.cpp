#include "ExportQueue.h"

namespace Fognitix::Export {

void ExportQueue::push(ExportJob job)
{
    std::scoped_lock lock(m_mutex);
    m_jobs.push_back(std::move(job));
}

bool ExportQueue::pop(ExportJob* out)
{
    std::scoped_lock lock(m_mutex);
    if (m_jobs.empty()) {
        return false;
    }
    *out = std::move(m_jobs.front());
    m_jobs.pop_front();
    return true;
}

} // namespace Fognitix::Export
