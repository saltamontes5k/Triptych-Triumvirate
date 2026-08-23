@echo off
setlocal EnableDelayedExpansion
rem ===========================================================================
rem  Windows build bootstrap
rem
rem  Generates Build\EQEmu.sln for YOUR machine, then you open it in Visual
rem  Studio and hit Build. The solution is deliberately NOT shipped: CMake bakes
rem  absolute paths into it, so a pre-made one from someone else's PC will not
rem  work on yours.
rem
rem  Requires: Visual Studio 2022 with the "Desktop development with C++"
rem  workload. That workload includes CMake, so there is usually nothing else
rem  to install - this script finds it automatically.
rem
rem  First run needs an internet connection: CMake downloads the prebuilt
rem  Windows dependencies (~132 MB) into vcpkg\ automatically.
rem ===========================================================================

cd /d "%~dp0"

echo.
echo  ===============================================
echo   NMS Server - Windows build setup
echo  ===============================================
echo.

rem ---- 1. Locate CMake -------------------------------------------------------
set "CMAKE_EXE="

rem  (a) on PATH?
where cmake >nul 2>&1
if %ERRORLEVEL%==0 (
    set "CMAKE_EXE=cmake"
    goto :found_cmake
)

rem  (b) bundled with Visual Studio - found via vswhere
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
        set "VSPATH=%%i"
    )
    if defined VSPATH (
        set "TRY=!VSPATH!\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
        if exist "!TRY!" (
            set "CMAKE_EXE=!TRY!"
            goto :found_cmake
        )
    )
)

echo  ERROR: CMake was not found.
echo.
echo   Easiest fix: install Visual Studio 2022 with the
echo   "Desktop development with C++" workload - it includes CMake.
echo     https://visualstudio.microsoft.com/downloads/
echo.
echo   Or install CMake on its own and make sure it is on your PATH:
echo     https://cmake.org/download/
echo.
pause
exit /b 1

:found_cmake
echo  Using CMake: %CMAKE_EXE%
"%CMAKE_EXE%" --version 2>nul | findstr /r /c:"cmake version"
echo.

rem ---- 2. Pick the generator -------------------------------------------------
rem  Change these two lines if you use a different Visual Studio version.
set "GENERATOR=Visual Studio 17 2022"
set "ARCH=x64"

echo  Generator: %GENERATOR%  (%ARCH%)
echo.
echo  Configuring into Build\ ...
echo  (first run downloads ~132 MB of dependencies - please be patient)
echo.

"%CMAKE_EXE%" -S . -B Build -G "%GENERATOR%" -A %ARCH% -DEQEMU_BUILD_LOGIN=ON
if not %ERRORLEVEL%==0 (
    echo.
    echo  ===============================================
    echo   CONFIGURE FAILED
    echo  ===============================================
    echo.
    echo   Common causes:
    echo     * No internet on the first run ^(dependencies could not download^)
    echo     * Visual Studio installed without the C++ workload
    echo     * A stale Build\ folder - delete it and run this again
    echo.
    pause
    exit /b 1
)

echo.
echo  ===============================================
echo   SUCCESS
echo  ===============================================
echo.
echo   Open this in Visual Studio:
echo       Build\EQEmu.sln
echo.
echo   Set the configuration to "Release" and "x64", then Build ^> Build Solution.
echo   Binaries land in Build\bin\Release\
echo.
echo   Prefer the command line? Run:
echo       "%CMAKE_EXE%" --build Build --config Release
echo.
pause
