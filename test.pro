QT       += core gui widgets multimedia multimediawidgets quickwidgets quick3d

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
INCLUDEPATH += \
    $$PWD/src \
    $$PWD/model

SOURCES += \
    coffeeviewer.cpp \
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
    coffeeviewer.h \
    model/coffee_cup.h \
    model/coffee_cup_2_texture.h \
    model/coffee_cup_texture.h \
    model/coffee_low.h \
    model/coffee_low_texture.h \
    model/simplify_coffee_cup.h \
    widget.h

FORMS += \
    widget.ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# This helps the compiler find the ARM headers if the Kit is being stubborn
#QMAKE_CXXFLAGS += --sysroot=$$[QT_SYSROOT]
#QMAKE_LFLAGS += --sysroot=$$[QT_SYSROOT]

DISTFILES += \
    coffee_scene.qml \
    media/brew-coffee-resize.mp4 \
    mesh-1.obj \
    mesh.obj

# --- Video Deployment Logic ---

# 1. Define where the media files should go on the G2L board
# We will put them in the same folder as the executable binary
media.path = \$$target.path/media
media.files = media/brew-coffee-resize.mp4

# 2. Tell QMake to include these in the 'install' process
INSTALLS += media

# 3. Optimization for Renesas G2L (Mali GPU)
# This ensures Qt uses the hardware acceleration for the video overlay
unix:!android {
    DEFINES += QT_VIDEOWIDGET_GLES
}


