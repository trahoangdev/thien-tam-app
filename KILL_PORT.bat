@echo off
REM Quick script to kill process on a specific port

if "%1"=="" (
    echo Usage: KILL_PORT.bat [port_number]
    echo Example: KILL_PORT.bat 4000
    exit /b 1
)

set PORT=%1

echo Killing process on port %PORT%...

for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%PORT%') do (
    set PID=%%a
)

if defined PID (
    taskkill /F /PID %PID%
    echo ✅ Killed process %PID% on port %PORT%
) else (
    echo ⚠️ No process found on port %PORT%
)

