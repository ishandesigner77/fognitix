# Build Fognitix using VS 2026 developer environment
param(
    [switch]$ConfigureOnly,
    [switch]$Clean
)

$ErrorActionPreference = "Continue"
$QtDir = "D:\Qt\6.8.3\msvc2022_64"
$VcpkgRoot = "D:\vcpkg"
$ProjectDir = "D:\FOGNITX"
$BuildDir = "$ProjectDir\build\windows-release"

Write-Host "[1/4] Loading VS 2026 developer environment..." -ForegroundColor Cyan

# Import VS dev shell
$vsDevShellDll = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
if (-not (Test-Path $vsDevShellDll)) {
    Write-Error "VS DevShell DLL not found at: $vsDevShellDll"
    exit 1
}

Import-Module $vsDevShellDll
Enter-VsDevShell -VsInstallPath "C:\Program Files\Microsoft Visual Studio\18\Community" -SkipAutomaticLocation -Arch amd64 -HostArch amd64

$clVer = & cl.exe 2>&1 | Select-Object -First 1
Write-Host "Compiler: $clVer" -ForegroundColor Green

Write-Host "[2/4] Configuring cmake..." -ForegroundColor Cyan
$env:VCPKG_ROOT = $VcpkgRoot
$env:CMAKE_PREFIX_PATH = $QtDir

$cmakeArgs = @(
    "-S", $ProjectDir,
    "-B", $BuildDir,
    "-G", "Ninja",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_PREFIX_PATH=$QtDir",
    "-DCMAKE_TOOLCHAIN_FILE=$VcpkgRoot\scripts\buildsystems\vcpkg.cmake",
    "-DFOGNITIX_ENABLE_OPENCV=OFF",
    "-DFOGNITIX_ENABLE_ONNX=OFF",
    "-DFOGNITIX_ENABLE_VULKAN=OFF",
    "-DVCPKG_MANIFEST_DIR=$ProjectDir",
    "-DVCPKG_INSTALLED_DIR=$BuildDir\vcpkg_installed"
)

$logFile = "$ProjectDir\cmake_configure.log"
Write-Host "Writing configure output to: $logFile"
& "D:\cmake\bin\cmake.exe" @cmakeArgs 2>&1 | Tee-Object -FilePath $logFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configure log:" -ForegroundColor Red
    Get-Content $logFile | Select-Object -Last 30
    Write-Error "CMake configure failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "[2/4] Configure OK" -ForegroundColor Green

if ($ConfigureOnly) { exit 0 }

Write-Host "[3/4] Building..." -ForegroundColor Cyan
$cpuCount = (Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
& "D:\cmake\bin\cmake.exe" --build $BuildDir --config Release --parallel $cpuCount
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "[4/4] Deploying Qt DLLs..." -ForegroundColor Cyan
$exePath = Get-ChildItem -Path $BuildDir -Filter "Fognitix.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($exePath) {
    & "$QtDir\bin\windeployqt.exe" --qmldir "$ProjectDir\src\ui" $exePath.FullName
    Write-Host ""
    Write-Host "=== BUILD SUCCESSFUL ===" -ForegroundColor Green
    Write-Host "Executable: $($exePath.FullName)" -ForegroundColor White
} else {
    Write-Error "Fognitix.exe not found after build!"
    exit 1
}
