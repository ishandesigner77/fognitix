#include "ThreadPool.h"

#include <algorithm>

#include <QThread>

namespace Fognitix::Engine {

namespace {

class FunctionRunnable final : public QRunnable {
public:
    explicit FunctionRunnable(std::function<void()> fn)
        : m_fn(std::move(fn))
    {
        setAutoDelete(true);
    }
    void run() override
    {
        if (m_fn) {
            m_fn();
        }
    }

private:
    std::function<void()> m_fn;
};

} // namespace

ThreadPool::ThreadPool()
{
    m_pool.setMaxThreadCount(std::max(2, QThread::idealThreadCount()));
}

ThreadPool::~ThreadPool() = default;

void ThreadPool::enqueue(std::function<void()> fn)
{
    m_pool.start(new FunctionRunnable(std::move(fn)));
}

} // namespace Fognitix::Engine
