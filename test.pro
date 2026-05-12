QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
INCLUDEPATH += \
    $$PWD/src \
    $$PWD/model

SOURCES += \
    main.cpp \
    src/Color.cpp \
    src/Fonts.cpp \
    src/Renderer3D.cpp \
    src/font_tgx_Arial.cpp \
    src/font_tgx_Arial_Bold.cpp \
    src/font_tgx_OpenSans.cpp \
    src/font_tgx_OpenSans_Bold.cpp \
    src/font_tgx_OpenSans_Italic.cpp \
    widget.cpp

HEADERS += \
    model/coffee_cup.h \
    model/coffee_cup_2_texture.h \
    model/coffee_cup_texture.h \
    widget.h

FORMS += \
    widget.ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# This helps the compiler find the ARM headers if the Kit is being stubborn
QMAKE_CXXFLAGS += --sysroot=$$[QT_SYSROOT]
QMAKE_LFLAGS += --sysroot=$$[QT_SYSROOT]

DISTFILES += \
    mesh-1.obj \
    mesh.obj

