@echo off
chcp 65001 >nul
title D6维修手册 - 局域网服务器

echo ============================================
echo   D6 FiniFB 维修手册 - 中文版
echo   局域网访问服务器
echo ============================================
echo.

:: Get local IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
)
set IP=%IP: =%

echo   启动中...
echo.
echo   本机访问:   http://localhost:8080
echo   手机访问:   http://%IP%:8080
echo.
echo   确保手机和电脑连接同一 WiFi 网络
echo   在手机浏览器输入上方地址即可访问
echo.
echo   按 Ctrl+C 停止服务器
echo ============================================
echo.

cd /d "%~dp0"
python -m http.server 8080

pause
