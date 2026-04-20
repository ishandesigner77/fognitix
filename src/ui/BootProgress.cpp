#include "BootProgress.h"

namespace Fognitix::UI {

BootProgress::BootProgress(QObject* parent)
    : QObject(parent)
{
    m_statusText = QStringLiteral("Starting…");
}

void BootProgress::setPhase(const QString& message, qreal progress01)
{
    const qreal p = qBound(0.0, progress01, 1.0);
    bool changed = false;
    if (m_statusText != message) {
        m_statusText = message;
        changed = true;
        emit statusTextChanged();
    }
    if (p > m_progress + 1e-6) {
        m_progress = p;
        emit progressChanged();
        changed = true;
    }
    Q_UNUSED(changed);
}

void BootProgress::finalize(const QString& message)
{
    m_statusText = message;
    emit statusTextChanged();
    m_progress = 1.0;
    emit progressChanged();
    if (!m_ready) {
        m_ready = true;
        emit readyChanged();
    }
}

} // namespace Fognitix::UI
