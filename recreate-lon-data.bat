@echo off
REM recreate-lon-data.bat - rebuilds the LoN card game data folder from a
REM stock RoF2 client copy. The card data (Daybreak copyright) ships with
REM every RoF2 client under LegendsOfNorrath\data and is never committed.
REM Usage: recreate-lon-data.bat ^<your-EQ-client-folder^>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: recreate-lon-data.bat ^<EQ-client-folder^>
    exit /b 1
)

set "CLIENT=%~1"
set "SRC=%CLIENT%\LegendsOfNorrath\data"
set "DEST=%~dp0Release-NMS-Server\Build\bin\Release\lon_data"

if not exist "%SRC%\archetypes\index.dat" (
    echo ERROR: %SRC% not found or incomplete.
    echo The Legends of Norrath data ships with the stock RoF2 client under
    echo LegendsOfNorrath\data - point this script at that client folder.
    exit /b 1
)

echo Copying LoN card data from %SRC% ...
robocopy "%SRC%" "%DEST%" /E /NFL /NDL /NJH /NP /R:1 /W:1 >nul
set "RC=%ERRORLEVEL%"
if %RC% GTR 7 (
    echo ERROR: robocopy failed with code %RC% - card data NOT complete.
    exit /b 1
)

if not exist "%DEST%\archetypes\storage.dat" (
    echo ERROR: %DEST%\archetypes\storage.dat missing after copy.
    exit /b 1
)

echo Done. Card data is in place at %DEST%.
echo Start the server and confirm world logs:
echo   [LoN] card service listening on port [15792]
echo Until then the card game simply stays off; nothing else is affected.
echo Details: Release-NMS-Server\docs\lon-card-data.md
endlocal
