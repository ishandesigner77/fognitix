#pragma once

#include <algorithm>
#include <functional>
#include <mutex>
#include <vector>

namespace Fognitix::State {

template <typename T>
class Observable {
public:
    using Listener = std::function<void(const T&)>;

    Observable() = default;
    explicit Observable(T initial)
        : m_value(std::move(initial))
    {
    }

    const T& value() const noexcept
    {
        return m_value;
    }

    void setValue(T next)
    {
        {
            std::scoped_lock lock(m_mutex);
            m_value = std::move(next);
        }
        notify();
    }

    void mutate(const std::function<void(T&)>& fn)
    {
        {
            std::scoped_lock lock(m_mutex);
            fn(m_value);
        }
        notify();
    }

    int addListener(Listener listener)
    {
        std::scoped_lock lock(m_mutex);
        const int id = m_nextId++;
        m_listeners.push_back({id, std::move(listener)});
        return id;
    }

    void removeListener(int id)
    {
        std::scoped_lock lock(m_mutex);
        m_listeners.erase(
            std::remove_if(
                m_listeners.begin(),
                m_listeners.end(),
                [id](const ListenerEntry& e) { return e.id == id; }),
            m_listeners.end());
    }

private:
    struct ListenerEntry {
        int id = 0;
        Listener listener;
    };

    void notify()
    {
        std::vector<ListenerEntry> copy;
        T snapshot;
        {
            std::scoped_lock lock(m_mutex);
            copy = m_listeners;
            snapshot = m_value;
        }
        for (const auto& entry : copy) {
            if (entry.listener) {
                entry.listener(snapshot);
            }
        }
    }

    mutable std::mutex m_mutex;
    T m_value{};
    std::vector<ListenerEntry> m_listeners;
    int m_nextId = 1;
};

} // namespace Fognitix::State
