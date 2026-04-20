#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

namespace Fognitix::UI {

class SystemMetrics : public QObject {
    Q_OBJECT
    Q_PROPERTY(double ramUsedFraction READ ramUsedFraction NOTIFY metricsChanged)
    Q_PROPERTY(double ramUsedGb READ ramUsedGb NOTIFY metricsChanged)
    Q_PROPERTY(double ramTotalGb READ ramTotalGb NOTIFY metricsChanged)
    Q_PROPERTY(double gpuLoadFraction READ gpuLoadFraction NOTIFY metricsChanged)
    Q_PROPERTY(QString gpuLabel READ gpuLabel NOTIFY metricsChanged)

public:
    explicit SystemMetrics(QObject* parent = nullptr);

    double ramUsedFraction() const noexcept { return m_ramUsedFraction; }
    double ramUsedGb() const noexcept { return m_ramUsedGb; }
    double ramTotalGb() const noexcept { return m_ramTotalGb; }
    double gpuLoadFraction() const noexcept { return m_gpuLoadFraction; }
    const QString& gpuLabel() const noexcept { return m_gpuLabel; }

signals:
    void metricsChanged();

private:
    void refresh();

    QTimer m_timer;
    double m_ramUsedFraction = 0.0;
    double m_ramUsedGb = 0.0;
    double m_ramTotalGb = 0.0;
    double m_gpuLoadFraction = 0.0;
    QString m_gpuLabel = QStringLiteral("—");
};

} // namespace Fognitix::UI
