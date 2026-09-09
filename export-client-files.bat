@echo off
REM export-client-files.bat — generates the 4 DB-derived client data files
REM and copies them into <client>\ and <client>\Resources\
REM Usage: export-client-files.bat ^<your-EQ-client-folder^>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: export-client-files.bat ^<EQ-client-folder^>
    exit /b 1
)

set "CLIENT=%~1"
set "EXE=Release-NMS-Server\Build\bin\Release\export_client_files.exe"
set "EXPORT=Release-NMS-Server\Build\bin\Release\export"

if not exist "!EXE!" (
    echo ERROR: !EXE! not found. Build the server first.
    exit /b 1
)

echo Running export_client_files.exe...
"!EXE!"

if not exist "!EXPORT!" (
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
