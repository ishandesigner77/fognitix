#include "PreviewImageProvider.h"

#include "core/state/AppState.h"

#include <QImage>

namespace Fognitix::UI {

PreviewImageProvider::PreviewImageProvider(Fognitix::State::AppState* state)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_state(state)
{
}

QImage PreviewImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    (void)id;
    if (!m_state) {
        return {};
    }
    QImage img = m_state->previewFrame();
    if (img.isNull()) {
        return {};
    }
    if (size) {
        *size = img.size();
    }
    if (requestedSize.isValid() && requestedSize.width() > 0 && requestedSize.height() > 0) {
        return img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    return img;
}

} // namespace Fognitix::UI
