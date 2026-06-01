#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "core/AppController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("RGCS");
    QGuiApplication::setOrganizationName("RGCS");
    QGuiApplication::setApplicationVersion("0.1.0");
    QQuickStyle::setStyle("Fusion");

    AppController controller;
    controller.initialize();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.loadFromModule("RGCS", "Main");
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
