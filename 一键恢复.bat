@echo off
chcp 65001 >nul
title QQ 机器人 - 一键恢复

REM ============================================================
REM  第一次用之前，改下面这四行，其余不用动
REM ============================================================
set "NAPCAT_HOME=D:\napcat"
set "NAPCAT_BAT=%NAPCAT_HOME%\launcher-user.bat"
set "ONEBOT_PORT=6199"
set "BOT_QQ=在这里填你的机器人QQ号"
REM ============================================================

set "QR=%NAPCAT_HOME%\cache\qrcode.png"
set "ONLY_CHECK="
if /i "%~1"=="check" set "ONLY_CHECK=1"

echo.
echo ================================================
echo   QQ 机器人一键恢复
echo ================================================
echo.
echo 配置：
echo   NapCat 目录 : %NAPCAT_HOME%
echo   启动脚本    : %NAPCAT_BAT%
echo   端口        : %ONEBOT_PORT%
echo.

if not exist "%NAPCAT_BAT%" (
    echo [!!] 找不到启动脚本：%NAPCAT_BAT%
    echo      请编辑本文件顶部的 NAPCAT_BAT，指向你自己的启动脚本。
    echo.
    pause
    exit /b 1
)

echo 当前状态：
netstat -ano | findstr ":%ONEBOT_PORT%" | findstr "ESTABLISHED" >nul
if not errorlevel 1 (echo   连接正常) else (echo   未连接)
echo.

if defined ONLY_CHECK (
    echo [检查模式] 不做任何修改。
    echo.
    pause
    exit /b 0
)

echo 注意：本脚本会无条件重启，即使当前显示"连接正常"。
echo       因为会出现"连接在、但不回消息"的假死状态，
echo       那种情况只有重启能救。
echo.
echo 3 秒后开始 ...
timeout /t 3 /nobreak >nul

echo.
echo [1/4] 关闭 QQ 和协议端 ...
taskkill /f /im NapCatWinBootMain.exe >nul 2>&1
taskkill /f /im QQ.exe >nul 2>&1
timeout /t 4 /nobreak >nul

echo [2/4] 清理旧二维码 ...
if exist "%QR%" del /f /q "%QR%" >nul 2>&1

echo [3/4] 启动协议端，等待 30 秒 ...
start "" /min cmd /c ""%NAPCAT_BAT%""
timeout /t 30 /nobreak >nul

echo [4/4] 检查结果 ...
netstat -ano | findstr ":%ONEBOT_PORT%" | findstr "ESTABLISHED" >nul
if not errorlevel 1 (
    echo.
    echo [OK] 已恢复，连接正常，不用扫码。
    echo.
    goto done
)

if exist "%QR%" (
    start "" "%QR%"
    echo.
    echo [!!] 需要扫码登录 %BOT_QQ%
    echo      二维码已弹出，用手机 QQ 扫。
    echo      两分钟内有效，过期了就重新运行本脚本。
    echo.
    goto done
)

echo.
echo [!!] 既没连上、也没生成二维码。
echo      检查协议端是否在运行，或打开它的 WebUI 看状态。
echo.

:done
echo ================================================
pause
