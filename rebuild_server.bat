@echo off
cd /d C:\EQS\Release-NMS-Server
"C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" --build Build --config Release
if errorlevel 1 exit /b 1

REM The zone/world processes read patch_RoF2.conf from the directory they run in, not
REM from utils\patches. Copy it on every successful build so a newly added opcode can
REM never resolve to 0x0000 because the runtime copy is stale.
copy /Y "utils\patches\patch_RoF2.conf" "Build\bin\Release\patch_RoF2.conf" >nul