@echo off
setlocal
title Triptych - Export Client Data Files
echo ==============================================
echo   Export client data files into your EQ client
echo ==============================================
echo.

rem ---- Locate the server folder (repo root\Release-NMS-Server) ----
set "SERVER=%~dp0Release-NMS-Server"
if not exist "%SERVER%\bin\Release\export_client_files.exe" (
    echo ERROR: Could not find %SERVER%\bin\Release\export_client_files.exe
    echo Make sure you have built the server (or shipped binaries are present).
    pause
    exit /b 1
)

rem ---- Require eqemu_config.json (copy from .example if missing) ----
if not exist "%SERVER%\eqemu_config.json" (
    echo ERROR: %SERVER%\eqemu_config.json not found.
    echo Copy eqemu_config.json.example to eqemu_config.json and set your DB credentials first.
    pause
    exit /b 1
)

rem ---- Run the exporter (writes Release-NMS-Server\export\*.txt) ----
echo  Running export_client_files ... 
pushd "%SERVER%"
call "%SERVER%\bin\Release\export_client_files.exe"
if errorlevel 1 (
    echo ERROR: export_client_files failed. Check the database connection.
    popd
    pause
    exit /b 1
)
popd

set "EXPORT=%SERVER%\export"
for %%F in (spells_us.txt dbstr_us.txt SkillCaps.txt BaseData.txt) do (
    if not exist "%EXPORT%\%%F" (
        echo ERROR: %EXPORT%\%%F was not generated.
        pause
        exit /b 1
    )
)

rem ---- Pick the EQ client folder ----
set "CLIENT=%~1"
if "%CLIENT%"=="" (
    set /p "CLIENT=Enter the path to your EverQuest client folder: "
)
if not exist "%CLIENT%" (
    echo ERROR: Client folder not found: %CLIENT%
    pause
    exit /b 1
)

rem ---- Copy into client root + Resources\ ----
for %%F in (spells_us.txt dbstr_us.txt SkillCaps.txt BaseData.txt) do (
    copy /Y "%EXPORT%\%%F" "%CLIENT%\%%F" >nul
    if exist "%CLIENT%\Resources\" copy /Y "%EXPORT%\%%F" "%CLIENT%\Resources\%%F" >nul
)

echo.
echo ==============================================
echo   Done. Copied to %CLIENT%\ (and Resources\)
echo     spells_us.txt
echo     dbstr_us.txt
echo     SkillCaps.txt
echo     BaseData.txt
echo   Re-run any time you change spells/skills/item text in the DB.
echo ==============================================
echo.
endlocal
