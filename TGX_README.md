# TGX + Qt on Linux Integration Guide
the TGX repo: https://github.com/vindar/tgx.git

## Purpose

This document records the full workflow for using the `tgx` library in a new Qt project, from 3D model conversion on a PC to running the application on a Linux target device such as a Renesas REMI Pi.

It is intended for:

- future reuse
- knowledge sharing with other engineers
- avoiding the same trial-and-error during next integration


## 1. What `tgx` Is

`tgx` is a CPU-side graphics library. It does not create a 3D window by itself and it is not an OpenGL scene engine.

Core concept:

- `tgx` renders into a memory framebuffer
- the application is responsible for displaying that framebuffer
- on MCU targets, the framebuffer is pushed to an LCD driver
- on Qt/Linux, the framebuffer is converted to a `QImage` and painted in a widget

This distinction is important:

- `tgx` is a software rasterizer
- Qt is used only as the UI/display framework
- there is no requirement to use OpenGL for the 3D model rendering itself


## 2. Important Library Structure

In the `tgx` source tree:

- `src/` contains the actual library code
- `examples/` shows the intended usage patterns
- `tools/obj_to_h.py` converts `.obj` mesh data into a `tgx::Mesh3D` header
- `tools/texture_2_h.py` converts texture images into `tgx` texture headers

Key files:

- `src/tgx.h`
- `src/Renderer3D.h`
- `src/Mesh3D.h`
- `src/Color.h`


## 3. Core Rendering Concept

The basic rendering flow is:

1. prepare a pixel buffer in RAM
2. wrap that buffer with `tgx::Image<color_t>`
3. prepare a z-buffer
4. create `tgx::Renderer3D<color_t>`
5. configure viewport, image, z-buffer, projection, shader state
6. draw the mesh into the framebuffer
7. display the framebuffer

In Qt, step 7 means:

- convert the framebuffer to a `QImage`
- draw it in `paintEvent()`


## 4. Model Format Limitation

`tgx` does **not** load `.glb` directly.

The provided mesh conversion tool only accepts Wavefront `.obj`.

Therefore the model pipeline is:

1. original model in `.glb`
2. convert `.glb` to `.obj` plus texture image files
3. convert `.obj` to a `tgx` mesh header
4. convert each texture image to a `tgx` texture header

Recommended conversion tools:

- Blender
- Assimp-based tools

Example with Blender:

- import `.glb`
- export as `.obj`
- make sure texture images are exported beside the `.obj`


## 5. Converting the Mesh

Tool:

- `tools/obj_to_h.py`

What it does:

- reads a `.obj`
- parses vertices, normals, texture coordinates, faces
- reorganizes mesh data into `tgx::Mesh3D`
- generates a `.h` file

Important input rules:

- do not leave the OBJ filename blank
- do not put the path inside quotes
- enter either a valid relative path or an absolute path

Correct examples:

```text
coffee_cup.obj
..\coffee_cup\coffee_cup.obj
C:\full\path\coffee_cup.obj
```

Wrong examples:

```text
"..\coffee_cup\coffee_cup.obj"

```

Why:

- the script appends `.obj` if needed
- quoted input can become `"file.obj".obj`
- blank input becomes `.obj`

The script is interactive. It may ask:

- OBJ filename
- whether to compute normals
- whether to recenter/rescale the mesh
- output model name
- default color/light settings
- texture names for each mesh object

This is important because the script can look "stuck" while actually waiting for input.


## 6. Converting Texture Images

Tool:

- `tools/texture_2_h.py`

What it expects:

- an original image file as input
- not a generated `.h`
- not a symbolic texture name

At:

```text
Texture image filename ?
```

you must enter the actual image file, for example:

```text
coffee_cup_diffuse.png
```

Later it asks:

```text
Name of the texture ?
```

This is the base symbol name to generate the output header.

Example:

- input image: `coffee_cup_diffuse.png`
- texture name entered: `coffee_cup`
- output file: `coffee_cup_texture.h`
- generated texture symbol: `coffee_cup_texture`

For a second texture:

- texture name entered: `coffee_cup_2`
- output file: `coffee_cup_2_texture.h`

Important:

- the name entered in `obj_to_h.py` must match the base name used in `texture_2_h.py`
- do not include `_texture`
- do not include `.h`


## 7. Why the Generated Model Uses `RGB565`

This is one of the most important integration points.

Generated textured model headers such as:

- `coffee_cup.h`
- `naruto.h`

typically define:

```cpp
const tgx::Mesh3D<tgx::RGB565> coffee_cup_1 = { ... };
```

Reason:

- `texture_2_h.py` generates texture images as `Image<RGB565>`
- therefore `obj_to_h.py` creates a mesh type compatible with `RGB565`

This means:

- `Renderer3D<RGB565>` must be used
- `Image<RGB565>` must be used
- the framebuffer should be `RGB565`

This is different from the CPU `buddha` example, which uses:

```cpp
Mesh3D<RGB32>
Renderer3D<RGB32>
Image<RGB32>
```

Why the difference:

- `buddha` is an untextured CPU example
- `coffee_cup` is a textured generated asset


## 8. Chained Meshes

Generated textured models are often split into multiple mesh objects.

Example pattern:

```cpp
const tgx::Mesh3D<tgx::RGB565> naruto_3 = { ..., nullptr, ... };
const tgx::Mesh3D<tgx::RGB565> naruto_2 = { ..., &naruto_3, ... };
const tgx::Mesh3D<tgx::RGB565> naruto_1 = { ..., &naruto_2, ... };
```

The same applies to `coffee_cup_1`, `coffee_cup_2`, etc.

Important implication:

- the entry point is the first mesh, such as `coffee_cup_1`
- you do not render a nonexistent single symbol like `coffee_cup`

Typical call:

```cpp
renderer.drawMesh(&coffee_cup_1, false);
```

Why this works:

- `false` means do not use per-mesh material settings
- the third parameter `draw_chained_meshes` defaults to `true`
- so linked meshes are rendered automatically


## 9. Qt Integration Concept

On Qt/Linux, `tgx` does not display directly.

The application does:

1. allocate a framebuffer in `RGB565`
2. render into it using `tgx`
3. convert each pixel to Qt's display format
4. draw that image in a widget

This conversion is necessary because Qt expects formats like:

- `QImage::Format_RGB32`

while `tgx` textured models use:

- `RGB565`


## 10. Recommended Project Layout

Example:

```text
test/
  main.cpp
  widget.cpp
  widget.h
  test.pro
  src/
    tgx library sources
  model/
    coffee_cup.h
    coffee_cup_texture.h
    coffee_cup_2_texture.h
```

This is a clean layout because:

- `src/` is the library code
- `model/` contains generated assets


## 11. qmake Build Setup

Example `test.pro`:

```pro
QT += core gui widgets
CONFIG += c++17

SOURCES += \
    main.cpp \
    widget.cpp \
    src/Color.cpp \
    src/Fonts.cpp \
    src/Renderer3D.cpp \
    src/font_tgx_Arial.cpp \
    src/font_tgx_Arial_Bold.cpp \
    src/font_tgx_OpenSans.cpp \
    src/font_tgx_OpenSans_Bold.cpp \
    src/font_tgx_OpenSans_Italic.cpp

HEADERS += \
    widget.h \
    model/coffee_cup.h \
    model/coffee_cup_texture.h \
    model/coffee_cup_2_texture.h

INCLUDEPATH += \
    $$PWD/src \
    $$PWD/model
```

Important:

- use `$$PWD`, not `$PWD`
- do not escape `$$PWD` with `\`

Wrong:

```pro
INCLUDEPATH += \$$PWD/src
```

That produces a literal include path like `-I$PWD/src`, which breaks header lookup.


## 12. Include Style

Given the project layout, explicit includes are the clearest:

```cpp
#include "src/tgx.h"
#include "model/coffee_cup.h"
```

This avoids ambiguity and makes it obvious where each file comes from.


## 13. Example Qt Widget Structure

Core members:

```cpp
std::vector<tgx::RGB565> framebuffer_;
std::vector<float> zbuffer_;
tgx::Image<tgx::RGB565>* image_;
tgx::Renderer3D<tgx::RGB565> renderer_;
```

Why `float` z-buffer:

- embedded examples often use `uint16_t` z-buffer to save RAM
- on PC/Linux and larger Linux targets, `float` is simpler and safer
- it avoids precision problems during early bring-up


## 14. Converting `RGB565` for Qt

From `Color.h`, `RGB565` exposes:

- `R`
- `G`
- `B`
- packed `val`

Recommended Qt conversion:

```cpp
QRgb rgb565ToQrgb(const tgx::RGB565 &c)
{
    return qRgb(c.R * 255 / 31,
                c.G * 255 / 63,
                c.B * 255 / 31);
}
```

Why this is preferred:

- it uses the semantic channels directly
- it avoids guessing packed bit layout
- it matches the abstraction exposed by the library


## 15. Matching the Renderer to the Model

This is the most common source of compile errors.

Wrong combination:

```cpp
tgx::Renderer3D<tgx::RGB32> renderer;
renderer.drawMesh(&coffee_cup_1, false);
```

Why wrong:

- `coffee_cup_1` is `Mesh3D<RGB565>`
- the renderer expects `Mesh3D<RGB32>`

Correct:

```cpp
tgx::Renderer3D<tgx::RGB565> renderer;
renderer.drawMesh(&coffee_cup_1, false);
```


## 16. Recommended Rendering Setup

Typical initialization:

```cpp
renderer_.setViewportSize(w, h);
renderer_.setOffset(0, 0);
renderer_.setImage(image_);
renderer_.setZbuffer(zbuffer_.data());
renderer_.setPerspective(45.0f, float(w) / float(h), 1.0f, 100.0f);
renderer_.setMaterial(tgx::RGBf(0.85f, 0.55f, 0.25f), 0.2f, 0.7f, 0.8f, 64);
renderer_.setCulling(1);
renderer_.setTextureQuality(tgx::SHADER_TEXTURE_NEAREST);
renderer_.setTextureWrappingMode(tgx::SHADER_TEXTURE_WRAP_POW2);
```

Typical frame rendering:

```cpp
image_->clear(tgx::RGB565_Cyan);
renderer_.clearZbuffer();
renderer_.setModelPosScaleRot({0.0f, 0.0f, -25.0f}, {9.0f, 9.0f, 9.0f}, angleDeg_);
renderer_.drawMesh(&coffee_cup_1, false);
```

Why these values:

- close to `naruto.ino`
- useful as an initial known-good camera and scale
- easier to bring up than guessing small desktop-like transforms


## 17. Ubuntu PC Validation

On Ubuntu PC, the binary can be built and tested locally first.

Typical output executable:

```text
build-test-Desktop-Debug/test
```

That binary is for local PC testing only.

If using a cross-compilation kit for the target, the target executable will be in another build directory, for example:

```text
build-test-G2L-Debug/test
build-test-G2L-Release/test
```

Always verify with:

```bash
file build-test-Desktop-Debug/test
file build-test-G2L-Debug/test
file build-test-G2L-Release/test
```

Expected:

- Ubuntu host build: `x86-64`
- REMI Pi target build: `aarch64`


## 18. Deploying to Renesas REMI Pi

Copy the target-built binary to the device, for example:

```sh
cp /mnt/test_20260511 ./
chmod +x ./test_20260511
```

Do not copy the desktop x86-64 executable to the ARM target.


## 19. Runtime Platform on REMI Pi

This target does not use `xcb`.

Observed available Qt platform plugins:

- `eglfs`
- `minimal`
- `minimalegl`
- `offscreen`
- `vnc`
- `wayland-egl`
- `wayland`

`xcb` was not available, so normal Linux desktop behavior does not apply.

### What failed

Running without a platform argument:

```text
Could not find the Qt platform plugin "xcb"
```

Running with `eglfs`:

```text
EGL library doesn't support Emulator extensions
```

From `QT_DEBUG_PLUGINS=1`, Qt loaded:

```text
/usr/lib64/plugins/egldeviceintegrations/libqeglfs-emu-integration.so
```

This means the target EGLFS integration was using the emulator backend, which was not appropriate for this real hardware setup.

### What worked

The working runtime command was:

```sh
./test_20260511 -platform wayland
```

Equivalent:

```sh
QT_QPA_PLATFORM=wayland ./test_20260511
```

Conclusion:

- the REMI Pi environment is Wayland-based
- this application should be launched using the Wayland platform plugin


## 20. Debugging Strategy

If the program does not launch:

1. check architecture with `file`
2. check available Qt plugins
3. run with:

```sh
QT_DEBUG_PLUGINS=1 ./app
```

4. try explicit platform:

```sh
./app -platform wayland
./app -platform minimal
./app -platform eglfs
```

If the program launches but shows no model:

1. verify the background color changes
2. verify `paintEvent()` is running
3. increase model scale
4. move model farther back on Z
5. start from the first chained mesh, such as `coffee_cup_1`
6. use the same rendering pattern as `naruto.ino`


## 21. Common Mistakes

### Wrong OBJ input

Problem:

- entering quoted path or blank input to `obj_to_h.py`

Effect:

- script tries to open invalid filename like `.obj` or `"file.obj".obj`

### Texture conversion misunderstanding

Problem:

- entering a symbolic name instead of an actual image file into `texture_2_h.py`

Effect:

- script cannot open the texture image

### Missing texture headers

Problem:

- running `obj_to_h.py` without running `texture_2_h.py`

Effect:

- generated mesh header includes texture headers that do not exist

### Mismatched color types

Problem:

- using `Renderer3D<RGB32>` with `Mesh3D<RGB565>`

Effect:

- compile-time template mismatch

### Wrong mesh symbol

Problem:

- trying to render `coffee_cup`

Effect:

- symbol not found

Correct:

- render `coffee_cup_1`

### Wrong qmake path syntax

Problem:

- `\$$PWD/src`

Effect:

- headers not found

### Wrong Qt runtime platform on target

Problem:

- relying on default `xcb`

Effect:

- application aborts on target

Correct:

- use `-platform wayland`


## 22. Recommended Reusable Workflow

### On PC Ubuntu

1. convert `.glb` to `.obj`
2. locate all texture images
3. run `obj_to_h.py`
4. run `texture_2_h.py` for each texture image
5. place generated files in `model/`
6. place `tgx/src` in project `src/`
7. configure qmake
8. build and test locally
9. cross-build for target

### On REMI Pi

1. copy ARM target executable
2. ensure executable permission
3. run with:

```sh
./app -platform wayland
```


## 23. Final Technical Summary

For generated textured `tgx` models on Linux Qt:

- convert `.glb` -> `.obj`
- convert `.obj` -> `Mesh3D<RGB565>` header
- convert textures -> `Image<RGB565>` headers
- use `Renderer3D<RGB565>`
- use `Image<RGB565>`
- render the first chained mesh, e.g. `coffee_cup_1`
- convert framebuffer to `QImage` in Qt
- build on Ubuntu, deploy ARM binary to REMI Pi
- launch on target with `-platform wayland`


## 24. References in `tgx`

Useful examples:

- `examples/CPU/buddhaOnCPU/buddhaOnCPU.cpp`
- `examples/ESP32/naruto/naruto.ino`
- `examples/Teensy4/3D/characters/characters.ino`
- `examples/Teensy4/3D/test-texture/test-texture.ino`

Useful tools:

- `tools/obj_to_h.py`
- `tools/texture_2_h.py`

Useful core headers:

- `src/tgx.h`
- `src/Renderer3D.h`
- `src/Mesh3D.h`
- `src/Color.h`


