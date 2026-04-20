@echo off
setlocal enabledelayedexpansion

set "VCPKG_ROOT=D:\vcpkg"
set "LOGFILE=D:\FOGNITX\cmake_config.log"

echo Configuring... > "%LOGFILE%"
echo. >> "%LOGFILE%"

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >> "%LOGFILE%" 2>&1
    echo VS2022 loaded >> "%LOGFILE%"
) else if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >> "%LOGFILE%" 2>&1
    echo VS18 loaded >> "%LOGFILE%"
) else (
    echo ERROR: No VS found >> "%LOGFILE%"
    exit /b 1
)

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo ERROR: vcpkg not found at %VCPKG_ROOT% >> "%LOGFILE%"
    exit /b 1
)

echo VCPKG_ROOT=%VCPKG_ROOT% >> "%LOGFILE%"

cd /d D:\FOGNITX
echo Running cmake configure... >> "%LOGFILE%"
"D:\cmake\bin\cmake.exe" --preset windows-release >> "%LOGFILE%" 2>&1
set EXIT_CODE=%ERRORLEVEL%
echo. >> "%LOGFILE%"
echo EXIT CODE: %EXIT_CODE% >> "%LOGFILE%"
exit /b %EXIT_CODE%
