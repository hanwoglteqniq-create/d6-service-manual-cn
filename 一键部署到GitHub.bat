@echo off
chcp 65001 >nul
title D6维修手册 - GitHub Pages 一键部署

echo ============================================
echo   D6 FiniFB 维修手册 - 中文版
echo   GitHub Pages 一键部署
echo ============================================
echo.

set GH=C:\Program Files\GitHub CLI\gh.exe
set GIT=C:\Program Files\Git\bin\git.exe
set REPO_DIR=%~dp0

:: Check environment
if not exist "%GH%" (
    echo [错误] 未找到 GitHub CLI
    echo 请先安装: winget install GitHub.cli
    echo 然后重启此脚本
    pause
    exit /b 1
)

:: Check if already logged in
"%GH%" auth status >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 已登录 GitHub
    goto :create_repo
)

echo [步骤1] 登录 GitHub
echo -----------------------------------------------
echo 请选择登录方式:
echo   1. 设备码登录 (推荐 - 在浏览器中操作)
echo   2. Token 登录 (粘贴 Personal Access Token)
echo.
set /p LOGIN_METHOD="请输入选择 (1 或 2): "

if "%LOGIN_METHOD%"=="1" (
    echo.
    echo 即将打开浏览器进行登录...
    echo 请在弹出的页面中完成 GitHub 授权
    "%GH%" auth login --hostname github.com --git-protocol https --web
    if errorlevel 1 (
        echo 登录失败！请重试
        pause
        exit /b 1
    )
    echo [OK] 登录成功
    goto :create_repo
)

if "%LOGIN_METHOD%"=="2" (
    echo.
    echo 请创建 Personal Access Token:
    echo   1. 打开 https://github.com/settings/tokens/new
    echo   2. Note 填写: D6 Manual Deploy
    echo   3. Expiration 选择时间范围
    echo   4. 勾选 repo 权限
    echo   5. 点击 Generate token 并复制
    echo.
    set /p TOKEN="请粘贴 Token (以 ghp_ 开头): "
    echo %TOKEN% | "%GH%" auth login --hostname github.com --git-protocol https --with-token
    if errorlevel 1 (
        echo Token 无效！请检查后重试
        pause
        exit /b 1
    )
    echo [OK] 登录成功
    goto :create_repo
)

echo 无效选择
pause
exit /b 1

:create_repo
echo.
echo [步骤2] 创建 GitHub 仓库
echo -----------------------------------------------
set REPO_NAME=d6-service-manual-cn

:: Check if repo already exists
"%GH%" repo view "%REPO_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo 仓库已存在，将更新内容...
    cd /d "%REPO_DIR%"
    "%GH%" repo set-default "%REPO_NAME%"
    "%GIT%" remote remove origin 2>nul
    "%GIT%" remote add origin https://github.com/%USERNAME%/%REPO_NAME%.git
    "%GIT%" push -u origin main --force
    goto :enable_pages
)

echo 创建新仓库: %REPO_NAME%
cd /d "%REPO_DIR%"
"%GH%" repo create "%REPO_NAME%" --public --source=. --remote=origin --push --description "D6 FiniFB Service Manual - Chinese PWA"
if errorlevel 1 (
    echo 创建仓库失败
    echo 你可以手动在 GitHub 上创建仓库，然后运行:
    echo   git remote add origin https://github.com/你的用户名/%REPO_NAME%.git
    echo   git push -u origin main
    pause
    exit /b 1
)

:enable_pages
echo.
echo [步骤3] 启用 GitHub Pages
echo -----------------------------------------------

:: Get the actual repo owner
for /f "tokens=*" %%i in ('"%GH%" repo view --json owner -q .owner.login') do set OWNER=%%i
echo 仓库所有者: %OWNER%

:: Enable Pages via API
"%GH%" api -X POST "repos/%OWNER%/%REPO_NAME%/pages" -f source[branch]=main -f source[path]="/" 2>nul
if errorlevel 1 (
    echo Pages 可能已启用，尝试更新...
    "%GH%" api -X PUT "repos/%OWNER%/%REPO_NAME%/pages" -f source[branch]=main -f source[path]="/"
)

echo.
echo ============================================
echo   部署完成！
echo ============================================
echo.
echo   访问地址:
echo   https://%OWNER%.github.io/%REPO_NAME%/
echo.
echo   GitHub Pages 通常需要 1-3 分钟生效
echo   可用以下命令查看状态:
echo     gh api repos/%OWNER%/%REPO_NAME%/pages
echo.
echo   手机使用:
echo   1. 在手机浏览器打开上述地址
echo   2. iOS Safari: 分享 → 添加到主屏幕
echo   3. Android Chrome: 菜单 → 添加到主屏幕
echo.
echo ============================================

pause
