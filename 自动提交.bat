@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set REPO_DIR=%~dp0

if "!REPO_DIR:~-1!" == "\" (
    set "REPO_DIR=!REPO_DIR:~0,-1!"
)

cd /d "%REPO_DIR%"

for /f "delims=" %%i in ('git status --porcelain') do (
    if not "%%i" == "" (

        git add .

        set TIME=%time:~0,5%
   
        set COMMIT_MSG=自动提交: %DATE% at !TIME!

        git commit -m "!COMMIT_MSG!"

        git push 
        
    )
)




 for /f "delims=" %%i in ('git status ') do (
    set aa=%%i
    set bb=!aa:~0,23!
    if "!bb!"=="Your branch is ahead of" (
        for /f "delims=" %%i in ('git status ') do (
            set aa=%%i
            set bb=!aa:~0,23!
            if "!bb!"=="Your branch is ahead of" (
                for /f "tokens=5 delims=: " %%a in ('netsh wlan show interfaces ^| findstr "SSID"') do (
                    set "SSID=%%a"
                )
                if defined SSID (
                    echo 当前连接的 WiFi 名称为: %SSID%
                    echo 自动提交失败，等待5分钟后自动重试。
                    ping -n 30 localhost >nul
                    echo 开始再次推送更改。
                        git push
                ) else (
                     echo 当前未连接任何 WiFi
                     echo 等待明天9:30自动重试。
                     schtasks /create /tn "tomorrow_auto_commit_github" /tr "%~f0" /sc once /st 07:07 /f
                    )
            )
        )
    )
)

schtasks /create /tn "auto_commit_github" /tr "%~f0" /sc daily /st 21:00 /f

endlocal