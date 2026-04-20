#include "SystemMetrics.h"

#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

#include <dxgi.h>
#include <wrl/client.h>
#endif

#include <algorithm>

#include <QtGlobal>

namespace Fognitix::UI {

SystemMetrics::SystemMetrics(QObject* parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &SystemMetrics::refresh);
    m_timer.start(800);
    refresh();
}

void SystemMetrics::refresh()
{
#ifdef Q_OS_WIN
    MEMORYSTATUSEX ms;
    ms.dwLength = sizeof(ms);
    if (GlobalMemoryStatusEx(&ms)) {
        m_ramUsedFraction = static_cast<double>(ms.dwMemoryLoad) / 100.0;
        const double total = static_cast<double>(ms.ullTotalPhys) / (1024.0 * 1024.0 * 1024.0);
        const double avail = static_cast<double>(ms.ullAvailPhys) / (1024.0 * 1024.0 * 1024.0);
        m_ramTotalGb = total;
        m_ramUsedGb = std::max(0.0, total - avail);
    }

    m_gpuLoadFraction = 0.0;
    m_gpuLabel = QStringLiteral("—");
    Microsoft::WRL::ComPtr<IDXGIFactory> factory;
    if (SUCCEEDED(CreateDXGIFactory(IID_PPV_ARGS(factory.GetAddressOf())))) {
        Microsoft::WRL::ComPtr<IDXGIAdapter> adapter;
        if (SUCCEEDED(factory->EnumAdapters(0, adapter.GetAddressOf()))) {
            DXGI_ADAPTER_DESC desc{};
            if (SUCCEEDED(adapter->GetDesc(&desc))) {
                m_gpuLabel = QString::fromWCharArray(desc.Description).trimmed();
                const double vramGb = static_cast<double>(desc.DedicatedVideoMemory) / (1024.0 * 1024.0 * 1024.0);
                if (vramGb > 0.05) {
                    m_gpuLabel += QStringLiteral(" · ") + QString::number(vramGb, 'f', 1) + QStringLiteral(" GB VRAM");
                }
            }
        }
    }
#else
    m_gpuLoadFraction = 0.0;
    m_gpuLabel = QStringLiteral("—");
#endif
    emit metricsChanged();
}

} // namespace Fognitix::UI
