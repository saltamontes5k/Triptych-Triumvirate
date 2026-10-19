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
rem ---- Refuse to double-start. A second ucs.exe cannot fail on its own: the chat
rem ---- port is bound with SO_REUSEADDR, so it starts, and then it and the live UCS
rem ---- evict each other from world's single UCS slot roughly 18 times a second.
rem ---- That floods every zone with UCS status changes (each one forces every client
rem ---- to re-handshake) and takes chat down until world is restarted.
for %%P in (loginserver.exe world.exe ucs.exe queryserv.exe eqlaunch.exe) do (
    "%SystemRoot%\System32\tasklist.exe" /FI "IMAGENAME eq %%P" /NH 2>nul | "%SystemRoot%\System32\findstr.exe" /I /C:"%%P" >nul
    if not errorlevel 1 (
        echo ERROR: %%P is already running.
        echo        Run stop-servers.bat first, then start-servers.bat.
        pause
        exit /b 1
    )
)

rem ---- Call timeout by full path. A Unix timeout from MSYS/Git earlier on PATH
rem ---- rejects '/t', so the stagger below silently does nothing and all five
rem ---- processes come up at once.

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

rem ---- Each service gets its own window so you can watch it, and nothing is
rem ---- redirected: you see the live output including the boot-time failures that
rem ---- happen *before* a process opens its own log file.
rem ----
rem ---- Optional: to ALSO keep a copy of a console, wrap that one command in
rem ---- PowerShell Tee-Object (it prints and writes at the same time), e.g.
rem ----   start "NMS World" /D "%BIN%" powershell -NoProfile -Command "& { .\world.exe 2>&1 | Tee-Object -FilePath logs\world_console.log -Append }"
rem ---- Redirecting with `>> file 2>&1` instead will make the window print nothing.
echo [1/5] LoginServer  (5999/udp client login)  ...
start "NMS LoginServer" /D "%BIN%" loginserver.exe

"%SystemRoot%\System32\timeout.exe" /t 3 /nobreak >nul

echo [2/5] World        (9000/udp clients, 9001/tcp zones) ...
start "NMS World" /D "%BIN%" world.exe

"%SystemRoot%\System32\timeout.exe" /t 3 /nobreak >nul

echo [3/5] UCS          (chat/mail) ...
start "NMS UCS" /D "%BIN%" ucs.exe

echo [4/5] QueryServ    (search/log queries) ...
start "NMS QueryServ" /D "%BIN%" queryserv.exe

echo [5/5] EQLaunch 'peq'  (dynamic zone pool, 7000-7300/udp; pool size set in DB launcher table) ...
start "NMS Zone Launcher (peq)" /D "%BIN%" eqlaunch.exe peq

echo.
echo ==============================================
echo   All servers launched. Watch the new windows.
echo   Each server has its own console window.
echo ==============================================
echo.
echo   To stop everything, run:  stop-servers.bat
echo.
endlocal
