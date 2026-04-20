@echo off
setlocal enabledelayedexpansion

set "VCPKG_ROOT=D:\vcpkg"
set "QT_DIR=D:\Qt\6.8.3\msvc2022_64"
set "LOGFILE=D:\FOGNITX\build_out.log"
set "CMAKE=D:\cmake\bin\cmake.exe"

echo. > "%LOGFILE%"
echo [%DATE% %TIME%] Build started >> "%LOGFILE%"

REM Load VS environment
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    echo VS2022 loaded >> "%LOGFILE%"
) else if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    echo VS18 loaded >> "%LOGFILE%"
) else (
    echo ERROR: Visual Studio not found >> "%LOGFILE%"
    exit /b 1
)

cd /d D:\FOGNITX

REM Configure
echo Configuring... >> "%LOGFILE%"
"%CMAKE%" --preset windows-release -DCMAKE_PREFIX_PATH="%QT_DIR%" >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo CONFIGURE FAILED >> "%LOGFILE%"
    type "%LOGFILE%"
    exit /b 1
)
echo Configure OK >> "%LOGFILE%"

REM Build
echo Building... >> "%LOGFILE%"
"%CMAKE%" --build --preset windows-release --parallel >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo BUILD FAILED >> "%LOGFILE%"
    type "%LOGFILE%"
    exit /b 1
)

echo BUILD COMPLETE >> "%LOGFILE%"
echo.
echo === BUILD SUCCESSFUL ===
where /r D:\FOGNITX\build\windows-release Fognitix.exe 2>nul
exit /b 0
