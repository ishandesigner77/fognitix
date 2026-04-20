# Fognitix

Professional native desktop video editor: **Qt 6** (QML UI), **C++20**, **CMake 3.28 + Ninja**, **vcpkg** dependencies, **FFmpeg** media I/O, **Vulkan/OpenGL** render façade, **SQLite** projects, **Groq** (`llama-3.3-70b-versatile`) AI command mode, **ONNX Runtime** / **OpenCV** for local analysis paths.

## Prerequisites (Windows)

- Visual Studio 2022 (C++ desktop workload)
- [CMake](https://cmake.org/) 3.28+
- [Ninja](https://ninja-build.org/)
- [vcpkg](https://github.com/microsoft/vcpkg) with `VCPKG_ROOT` set
- Optional: [Vulkan SDK](https://vulkan.lunarg.com/) for full Vulkan validation layers

## Configure and build

**First time:** `cmake --preset …` runs **vcpkg**, which compiles Qt, FFmpeg, OpenCV, ONNX Runtime, and more from source. Expect **roughly one to several hours** once; later rebuilds are much faster.

**Important:** run **only one** configure/install at a time. If **Visual Studio** is already configuring the same folder **and** you run `cmake` in a terminal (or Cursor), vcpkg will sit on `vcpkg-running.lock` (“waiting to take filesystem lock”) until the other run finishes. Close the duplicate configure, or stop the extra terminal job, then retry.

Set **`VCPKG_ROOT`** to your vcpkg clone (for example `D:\vcpkg`) and ensure **`cmake`** and **`ninja`** are on `PATH`, or use the helper script `build\_build_release.bat` after opening a **x64 Native Tools** / **Developer** environment (or it calls `vcvars64.bat` for you).

```powershell
cd Fognitix
cmake --preset windows-release
cmake --build --preset windows-release
ctest --preset windows-release
```

Debug with ASan-style toggles (off by default):

```powershell
cmake --preset windows-debug -DFOGNITIX_ENABLE_SANITIZERS=ON
cmake --build --preset windows-debug
```

## Run

```powershell
.\build\windows-release\Fognitix.exe
```

Set your Groq API key in **Settings → AI** (stored via Windows Credential Manager wrapper when available).

## Shaders and GLSL vs HLSL

GPU passes ship as **GLSL 4.60** under `shaders/`. The engine targets **Vulkan SPIR-V** and **OpenGL** paths from the same sources where possible. A future **D3D12 + HLSL 5.1** backend would compile separately; it is not required for the Qt Quick + RHI/Vulkan-GL interop façade in this repository.

## Effect registry

`tools/gen_effect_registry.py` generates `registry.generated.json` in the build tree at configure time (1000 data-driven effect entries). CMake invokes it before resources are compiled.

## Installer

NSIS script: `installer/fognitix_installer.nsi`. After `cmake --install` into a staging prefix, point NSIS at that tree or adjust `OUTFILE` / source paths in the script.

## License

Proprietary — Fognitix. Third-party libraries retain their respective licenses (Qt, FFmpeg, etc.).
