@echo off
setlocal
title NMS Server - STOP ALL
echo ==============================================
echo   NMS Server - Stopping all server processes
echo ==============================================
echo.

echo  Stopping zone processes (if any) ...
taskkill /IM zone.exe /F 2>nul

echo  Stopping zone launcher ...
taskkill /IM eqlaunch.exe /F 2>nul

echo  Stopping queryserv ...
taskkill /IM queryserv.exe /F 2>nul

echo  Stopping ucs ...
taskkill /IM ucs.exe /F 2>nul

echo  Stopping world ...
taskkill /IM world.exe /F 2>nul

echo  Stopping loginserver ...
taskkill /IM loginserver.exe /F 2>nul

echo.
echo ==============================================
echo   All server processes stopped.
echo ==============================================
echo.
endlocal
