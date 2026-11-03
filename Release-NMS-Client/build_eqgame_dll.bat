@echo off
cd /d "C:\EQS\Release-NMS-Client"
"C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" eqgame_dll.sln /p:Configuration=Release /p:Platform=Win32 /p:WindowsTargetPlatformVersion=10.0.19041.0 /p:PlatformToolset=v143 /m /v:m /nologo
