@echo off
rem Uso: compilar ruta\programa.asm   -> genera build\programa.dsk
rem RASM se comparte con el proyecto Amstrad_asm (no se copia).
setlocal
if "%~1"=="" (echo Uso: compilar ^<ruta\programa.asm^> & exit /b 1)
if not exist "%~f1" (echo No existe: %~1 & exit /b 1)
set "ASM=%~f1"
set "NOMBRE=%~n1"
cd /d "%~dp0"
if not exist build mkdir build
if exist "build\%NOMBRE%.dsk" del "build\%NOMBRE%.dsk"
..\Amstrad_asm\tools\rasm\rasm.exe "%ASM%" -o "build\%NOMBRE%"
