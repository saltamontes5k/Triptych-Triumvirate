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
rem  Requires: Visual Studio 2019 or newer with the "Desktop development with
rem  C++" workload (2022 and 2026 are both known to work). That workload
rem  includes CMake, so there is usually nothing else to install - this script
rem  finds it automatically and picks the matching CMake generator for you.
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
echo   Easiest fix: install Visual Studio (2019 or newer) with the
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
rem  Three-step resolution, most specific first:
rem    a) EQEMU_GENERATOR env var, if the caller set one.
rem    b) The VS major version vswhere already found, mapped to a real generator
rem       name via the CMake on this machine, so no year table to maintain.
rem    c) "Visual Studio 17 2022" as a last-resort fallback.
rem
rem  For step b, "cmake --help" lists generators like this:
rem      * Visual Studio 18 2026        = Generates ...
rem        Visual Studio 17 2022        = Generates ...
rem  The leading "*" just marks CMake's default. So we match on the generator
rem  name only, never anchored to column 0, which the "*" would otherwise hide.
rem  Splitting on "=" drops the description; then strip the marker and padding.
rem
set "ARCH=x64"
set "GENERATOR="
set "GENSRC="

if defined EQEMU_GENERATOR (
    set "GENERATOR=%EQEMU_GENERATOR%"
    set "GENSRC=from EQEMU_GENERATOR"
    goto :gen_done
)

rem  Step b, part 1: installationVersion looks like 18.10.12217.157, and the
rem  major version is just the first dot-separated field.
set "VSMAJOR="
if defined VSPATH if exist "%VSWHERE%" (
    for /f "usebackq tokens=1 delims=." %%v in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationVersion`) do (
        if not defined VSMAJOR set "VSMAJOR=%%v"
    )
)

if defined VSMAJOR (
    rem  Call cmake by NAME inside the for /f below, not via %CMAKE_EXE%. A
    rem  quoted executable path containing spaces gets re-split by the nested
    rem  command parser and fails with "'C:\Program' is not recognized".
    rem  Prepending CMake's own directory to PATH keeps our CMake first.
    for %%d in ("%CMAKE_EXE%") do set "PATH=%%~dpd;%PATH%"
    set "GEN_RAW="
    for /f "usebackq tokens=1* delims==" %%a in (`cmake --help ^| findstr /c:"Visual Studio %VSMAJOR% "`) do (
        if not defined GEN_RAW set "GEN_RAW=%%a"
    )
    if defined GEN_RAW (
        rem  :pick strips the leading "*" default marker and the column padding.
        call :pick "!GEN_RAW!" GEN_NAME
        if defined GEN_NAME set "GENERATOR=!GEN_NAME!"
    )
)

if not defined GENERATOR (
    set "GENERATOR=Visual Studio 17 2022"
    set "GENSRC=fallback, set EQEMU_GENERATOR to override"
    echo  WARNING: no CMake generator matched Visual Studio !VSMAJOR!.
    echo  WARNING: falling back to the hardcoded default.
)

if not defined GENSRC set "GENSRC=detected from Visual Studio %VSMAJOR%"

:gen_done
rem  No parentheses on this echo: see the note about "(" in echo inside a block.
echo  Generator: %GENERATOR%  - %ARCH% - !GENSRC!
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
exit /b 0

rem ---- helper: normalise one generator entry from "cmake --help" into %2 ------
rem  Input is the text before "=", e.g. "* Visual Studio 18 2026        ".
rem  Output is the bare name, e.g. "Visual Studio 18 2026".
:pick
setlocal EnableDelayedExpansion
set "_raw=%~1"
if "!_raw:~0,1!"=="*" set "_raw=!_raw:~1!"
for /f "tokens=*" %%a in ("!_raw!") do set "_raw=%%a"
for /L %%i in (1,1,20) do (
    if not "!_raw:  =!"=="!_raw!" set "_raw=!_raw:  =!"
)
if "!_raw:~-1!"==" " set "_raw=!_raw:~0,-1!"
endlocal & set "%~2=%_raw%"
goto :eof
