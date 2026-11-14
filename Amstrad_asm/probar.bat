@echo off
rem Uso: probar ruta\programa.asm   -> compila y, si no hay errores, ejecuta
call "%~dp0compilar.bat" "%~1" || exit /b 1
call "%~dp0ejecutar.bat" "%~1"
