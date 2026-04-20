#pragma once

#include <functional>

#include <QQuickImageProvider>
#include <QString>

namespace Fognitix::UI {

class WaveformImageProvider : public QQuickImageProvider {
public:
    using PathResolver = std::function<QString(const QString& mediaId)>;

    explicit WaveformImageProvider(PathResolver resolver);

    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    PathResolver m_resolver;
};

} // namespace Fognitix::UI
