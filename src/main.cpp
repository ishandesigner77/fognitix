#include <QCoreApplication>
#include <QGuiApplication>
#include <QSurfaceFormat>
#include <QQuickStyle>
#include <QtGlobal>

#include "Application.h"

int main(int argc, char* argv[])
{
    // Qt Quick defaults to the RHI; D3D12 can fail on some hybrid-GPU / driver setups with no visible window.
    if (qEnvironmentVariableIsEmpty("QSG_RHI_BACKEND")) {
        qputenv("QSG_RHI_BACKEND", "opengl");
    }
    if (qEnvironmentVariableIntValue("FOGNITIX_SOFTWARE_GL") != 0) {
        QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    }

    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    // OpenGL 4.6 Core is too strict for many integrated GPUs; Qt Quick works well on 3.3+ Core.
    QSurfaceFormat fmt;
    fmt.setDepthBufferSize(24);
    fmt.setStencilBufferSize(8);
    fmt.setRenderableType(QSurfaceFormat::OpenGL);
    fmt.setVersion(3, 3);
    fmt.setProfile(QSurfaceFormat::CoreProfile);
    QSurfaceFormat::setDefaultFormat(fmt);

    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("Fognitix"));
    QCoreApplication::setOrganizationName(QStringLiteral("Fognitix"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("fognitix.local"));

    Fognitix::Application fognitix(app);
    return fognitix.exec();
}
