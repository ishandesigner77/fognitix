QT += core gui widgets quick quickcontrols2 concurrent sql network svg opengl openglwidgets
CONFIG += c++20

TARGET = Fognitix
TEMPLATE = app

SOURCES += \
    src/main.cpp \
    src/Application.cpp

HEADERS += \
    src/Application.h

INCLUDEPATH += src

# Note: The canonical build is CMake + vcpkg + Ninja. This .pro file is a convenience skeleton for Qt Creator browsing.
