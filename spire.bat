@echo off
setlocal
title NMS Server - SPIRE
echo ==============================================
echo   NMS Server - Spire admin panel
echo ==============================================
echo.

set "SERVER=%~dp0Release-NMS-Server"
set "SPIRE_URL=http://127.0.0.1:8090"

if not exist "%SERVER%\spire.exe" (
    echo ERROR: Could not find %SERVER%\spire.exe
    pause
    exit /b 1
)

tasklist /FI "IMAGENAME eq spire.exe" 2>nul | find /I "spire.exe" >nul
if errorlevel 1 goto startspire

rem ---- already running: stop it ----
echo  Spire is already running - stopping it ...
set /a kills=0
:stoploop
taskkill /IM spire.exe /F >nul 2>&1
ping -n 3 127.0.0.1 >nul
tasklist /FI "IMAGENAME eq spire.exe" 2>nul | find /I "spire.exe" >nul
if errorlevel 1 goto stoppedok
set /a kills+=1
if %kills% lss 5 goto stoploop
echo ERROR: Failed to stop spire.exe
pause
exit /b 1

:stoppedok
echo.
echo ==============================================
echo   Spire stopped.
echo ==============================================
echo.
endlocal
exit /b 0

:startspire
echo  Starting Spire from %SERVER% ...
start "NMS Spire" /D "%SERVER%" spire.exe

echo  Waiting for web UI on %SPIRE_URL% ...
set /a tries=0
:waitloop
ping -n 3 127.0.0.1 >nul
powershell -NoProfile -Command "try { Invoke-WebRequest -UseBasicParsing -Uri '%SPIRE_URL%' -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if not errorlevel 1 goto up
set /a tries+=1
if %tries% lss 15 goto waitloop
echo WARNING: Web UI did not respond yet. It may still be starting,
echo          or eqemu_config.json could not be parsed.
goto done

:up
echo  Web UI is up.
start "" "%SPIRE_URL%"

:done
echo.
echo ==============================================
echo   Spire launched. Panel: %SPIRE_URL%
echo   Run this script again to stop Spire.
echo ==============================================
echo.
endlocal
