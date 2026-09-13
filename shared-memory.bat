@echo off
setlocal
title NMS Server - SHARED MEMORY
echo ==============================================
echo   NMS Server - Shared Memory (optional)
echo   Loads spells, items, and other shared
echo   data into memory for zone processes.
echo ==============================================
echo.

set "BIN=%~dp0Release-NMS-Server\Build\bin\Release"

if not exist "%BIN%\shared_memory.exe" (
    echo ERROR: Could not find %BIN%\shared_memory.exe
    echo Make sure you ran the build first.
    pause
    exit /b 1
)

rem ---- MariaDB client tools for shared_memory (needs mysql on PATH) ----
set "MYSQL_BIN="
if exist "%ProgramFiles%\MariaDB 12.3\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB 12.3\bin"
if not defined MYSQL_BIN if exist "%ProgramFiles%\MariaDB 11.4\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB 11.4\bin"
if not defined MYSQL_BIN if exist "%ProgramFiles%\MariaDB\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB\bin"
if defined MYSQL_BIN (
    set "PATH=%MYSQL_BIN%;%PATH%"
    echo MariaDB client tools found at %MYSQL_BIN%
) else (
    echo WARNING: MariaDB client tools not found on PATH
)

echo Launching shared_memory.exe ...
start "NMS SharedMemory" /D "%BIN%" shared_memory.exe
echo.
echo Shared memory started. Watch the new window.
echo.
endlocal