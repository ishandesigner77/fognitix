#pragma once

#include <functional>

#include <QQuickImageProvider>
#include <QString>

namespace Fognitix::UI {

class ThumbnailImageProvider : public QQuickImageProvider {
public:
    using PathResolver = std::function<QString(const QString& mediaId)>;

    explicit ThumbnailImageProvider(PathResolver resolver);

    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    PathResolver m_resolver;
};

} // namespace Fognitix::UI
