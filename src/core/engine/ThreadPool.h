#pragma once

#include <functional>

#include <QRunnable>
#include <QThreadPool>

namespace Fognitix::Engine {

class ThreadPool {
public:
    ThreadPool();
    ~ThreadPool();

    void enqueue(std::function<void()> fn);

private:
    QThreadPool m_pool;
};

} // namespace Fognitix::Engine
