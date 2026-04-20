#pragma once

#include <QObject>
#include <QString>

namespace Fognitix::UI {

/// Drives splash / startup status from real Application initialization order.
class BootProgress final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)

public:
    explicit BootProgress(QObject* parent = nullptr);

    QString statusText() const { return m_statusText; }
    qreal progress() const { return m_progress; }
    bool ready() const { return m_ready; }

    /// Updates status; progress only moves forward (monotonic).
    void setPhase(const QString& message, qreal progress01);

    /// Marks boot complete (typically after QML root loads).
    void finalize(const QString& message = QStringLiteral("Ready."));

signals:
    void statusTextChanged();
    void progressChanged();
    void readyChanged();

private:
    QString m_statusText;
    qreal m_progress = 0.0;
    bool m_ready = false;
};

} // namespace Fognitix::UI
