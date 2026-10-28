@echo off
rem Ejecutar con clic derecho -> "Ejecutar como administrador"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restaurar-nvram-wifi.ps1"
