@echo off
chcp 65001 > nul
title MaxBat.ua - Локальний сервер (порт 8080)
echo ===================================================
echo   MAXBAT - Локальний веб-сервер
echo ===================================================
echo Сервер запущено на http://localhost:8080
start "" "http://localhost:8080"
cd /d "%~dp0"
python -m http.server 8080
pause
