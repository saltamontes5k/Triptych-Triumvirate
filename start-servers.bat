@echo off
setlocal
title NMS Server - START ALL
echo ==============================================
echo   NMS Server - Starting all server processes
echo ==============================================
echo.

set "BIN=%~dp0Release-NMS-Server\Build\bin\Release"

if not exist "%BIN%\loginserver.exe" (
    echo ERROR: Could not find %BIN%
    echo Make sure you ran the build first.
    pause
    exit /b 1
)

rem ---- Perl runtime for quest scripting (REQUIRED: without this, all quests fail to load) ----
set "PERL_DIR=%~dp0Release-NMS-Server\perl\x64\perl"
if exist "%PERL_DIR%\bin\perl.exe" (
    set "PERL5LIB=%PERL_DIR%\site\lib;%PERL_DIR%\vendor\lib;%PERL_DIR%\lib"
    set "PATH=%PERL_DIR%\bin;%PATH%"
    echo Perl quest runtime found at %PERL_DIR%
) else (
    echo WARNING: Perl runtime not found at %PERL_DIR%
)

rem ---- MariaDB client tools for the manifest auto-updater (needs mysql/mysqldump on PATH) ----
set "MYSQL_BIN="
if exist "%ProgramFiles%\MariaDB 12.3\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB 12.3\bin"
if not defined MYSQL_BIN if exist "%ProgramFiles%\MariaDB 11.4\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB 11.4\bin"
if not defined MYSQL_BIN if exist "%ProgramFiles%\MariaDB\bin\mysql.exe" set "MYSQL_BIN=%ProgramFiles%\MariaDB\bin"
if defined MYSQL_BIN (
    set "PATH=%MYSQL_BIN%;%PATH%"
    echo MariaDB client tools found at %MYSQL_BIN%
) else (
    echo WARNING: MariaDB client tools not found - manifest DB backups will fail
)

echo [1/5] LoginServer  (5999/udp client login)  ...
start "NMS LoginServer" /D "%BIN%" loginserver.exe

timeout /t 3 /nobreak >nul

echo [2/5] World        (9000/udp clients, 9001/tcp zones) ...
start "NMS World" /D "%BIN%" world.exe

timeout /t 3 /nobreak >nul

echo [3/5] UCS          (chat/mail) ...
start "NMS UCS" /D "%BIN%" ucs.exe

echo [4/5] QueryServ    (search/log queries) ...
start "NMS QueryServ" /D "%BIN%" queryserv.exe

echo [5/5] EQLaunch 'peq' (boots zones on demand, 7000-7300/udp) ...
start "NMS Zone Launcher" /D "%BIN%" eqlaunch.exe peq

echo.
echo ==============================================
echo   All servers launched. Watch the new windows.
echo   Each server has its own console window.
echo ==============================================
echo.
echo   To stop everything, run:  stop-servers.bat
echo.
endlocal
