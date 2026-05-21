# RZ/G2L Qt6 Quick 3D Coffee Demo

This project demonstrates high-performance 3D hardware-accelerated rendering on the **Renesas RZ/G2L** MPU using **Qt 6.x** and **Qt Quick 3D**. 

By utilizing the onboard **ARM Mali-G31 GPU** via the **EGL/Wayland** pipeline, this application achieves smooth 3D visualization that far exceeds the capabilities of traditional software rendering.

## 🚀 Hardware Acceleration
This application is **not** using software rendering. It is fully hardware-accelerated:
*   **GPU:** ARM Mali-G31.
*   **Interface:** EGL / Wayland-EGL.
*   **Backend:** Qt Quick 3D (Spatial engine).
*   **Process:** 3D meshes are processed directly by the GPU, allowing for real-time lighting, materials, and smooth rotations.

## 📂 Project Structure
*   `3Dmodel/` - Contains original `.glb` files and the converted `.qml` assets.
*   `src/` - Core C++ logic and view controllers.
*   `coffee_scene.qml` - Main 3D scene definition (lights, camera, and model instances).
*   `test.pro` - Qt project configuration for cross-compilation.

## 🛠 Prerequisites
*   **Hardware:** Renesas RZ/G2L SMARC EVK.
*   **OS:** Linux with Weston/Wayland compositor.
*   **SDK:** Renesas VLP 5.0.11 or newer (Cortex-A55).
*   **Qt Version:** Qt 6.11.1+ with Quick 3D module installed.

## 🔨 Build Instructions
On your Ubuntu host machine, navigate to the project directory and run:

1. **Source the Cross-Compilation Environment:**
   ```bash
   source /opt/rz-vlp/5.0.11/environment-setup-cortexa55-poky-linux
   ```
2. **Generate Makefile and Compile:**
   ```bash
   qmake test.pro
   make -j$(nproc)
   ```

