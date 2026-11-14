@echo off
rem Uso: ejecutar ruta\programa.asm   -> abre build\programa.dsk y lanza RUN"PROGRAMA.BIN"
setlocal
if "%~1"=="" (echo Uso: ejecutar ^<ruta\programa.asm^> & exit /b 1)
set "NOMBRE=%~n1"
set "DSK=%~dp0build\%NOMBRE%.dsk"
if not exist "%DSK%" (echo No existe %DSK%. Compila primero. & exit /b 1)
taskkill /im cap32.exe >nul 2>&1
cd /d "%~dp0tools\cap32"
start "" cap32.exe "%DSK%" -a "run\"%NOMBRE%.bin"
