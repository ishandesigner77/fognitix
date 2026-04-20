#pragma once

#include <QQuickImageProvider>

namespace Fognitix::State {
class AppState;
}

namespace Fognitix::UI {

class PreviewImageProvider : public QQuickImageProvider {
public:
    explicit PreviewImageProvider(Fognitix::State::AppState* state);

    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    Fognitix::State::AppState* m_state = nullptr;
};

} // namespace Fognitix::UI
