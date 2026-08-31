@echo off
cd /d C:\EQS\Release-NMS-Server
"C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" --build Build --config Release
if errorlevel 1 exit /b 1