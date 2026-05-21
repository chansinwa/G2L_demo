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
    3Dmodel/coffee_cups_low_poly.glb \
    3Dmodel/coffee_cups_low_poly/coffee_BLACK_baseColor.png \
    3Dmodel/coffee_cups_low_poly/coffee_CAPPUCCINO_baseColor.png \
    3Dmodel/coffee_cups_low_poly/coffee_LATTE_baseColor.png \
    3Dmodel/coffee_cups_low_poly/coffee_cups_low_poly.mtl \
    3Dmodel/convert_model/Latte/Latte.qml \
    3Dmodel/convert_model/Latte/meshes/cube_050_mesh.mesh \
    3Dmodel/convert_model/Latte/meshes/cube_051_mesh.mesh \
    3Dmodel/convert_model/Latte/meshes/cylinder_028_mesh.mesh \
    3Dmodel/convert_model/Latte/meshes/cylinder_029_mesh.mesh \
    3Dmodel/convert_model/low_poly_coffee/Low_poly_coffee_cup.qml \
    3Dmodel/convert_model/low_poly_coffee/maps/textureData.png \
    3Dmodel/convert_model/low_poly_coffee/meshes/cylinder_0_mesh.mesh \
    3Dmodel/convert_model/low_poly_coffee/meshes/cylinder_1_mesh.mesh \
    3Dmodel/latte.glb \
    3Dmodel/low_poly_coffee_cup.glb \
    3Dmodel/low_poly_coffee_cup/Coffee_baseColor.png \
    3Dmodel/low_poly_coffee_cup/low_poly_coffee_cup.mtl \
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


