@echo off
REM export-client-files.bat - generates the 4 DB-derived client data files
REM and copies them into <client>\ and <client>\Resources\
REM Usage: export-client-files.bat ^<your-EQ-client-folder^>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: export-client-files.bat ^<EQ-client-folder^>
    exit /b 1
)

set "CLIENT=%~1"
set "EXEDIR=%~dp0Release-NMS-Server\bin\Release"
set "EXPORT=%EXEDIR%\export"

if not exist "%EXEDIR%\export_client_files.exe" (
    echo ERROR: %EXEDIR%\export_client_files.exe not found.
    echo Build the server first, or confirm Release-NMS-Server\bin\Release exists.
    exit /b 1
)

echo Running export_client_files.exe...
rem The exporter must run with its CWD set to the bin directory (it loads eqemu_config.json from there).
pushd "%EXEDIR%"
export_client_files.exe
set "EXERR=%ERRORLEVEL%"
popd
if not "%EXERR%"=="0" (
    echo ERROR: export_client_files.exe failed with code %EXERR% - NOT copying stale exports.
    exit /b 1
)

if not exist "%EXPORT%" (
    echo ERROR: export folder not created.
    exit /b 1
)

for %%F in (spells_us.txt dbstr_us.txt SkillCaps.txt BaseData.txt) do (
    if exist "!EXPORT!\%%F" (
        copy /Y "!EXPORT!\%%F" "!CLIENT!\%%F" >nul
        if exist "!CLIENT%\Resources\%%F" (
            copy /Y "!EXPORT!\%%F" "!CLIENT%\Resources\%%F" >nul
        ) else (
            mkdir "!CLIENT%\Resources" 2>nul
            copy /Y "!EXPORT!\%%F" "!CLIENT%\Resources\%%F" >nul
        )
        echo Copied %%F
    ) else (
        echo WARNING: !EXPORT!\%%F not found
    )
)

echo Done.
endlocal
