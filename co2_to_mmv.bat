@echo off

setlocal enabledelayedexpansion

set count=0
set newExtension=mmv
set targetExtension=co2

for /d %%D in ("%APPDATA%\Nightreign\*") do (
    set /a count+=1
    set "folders[!count!]=%%D"
)

if %count% equ 0 (
    echo Can't find any Steam ID folders
    pause
    exit /b 1
)

if %count% gtr 1 (
    echo Select Steam ID to convert save.
    for /l %%i in (1,1,%count%) do (
        echo %%i. !folders[%%i]!
    )
    call :Select
    call set "selected=%%folders[!choice!]%%"
) else (
    set "selected=!folders[1]!"
)

echo %selected%
for /f %%i in ('powershell -noprofile -command "Get-Date -Format \"yyyy-MM-dd_HH-mm-ss\""') do set "datetime=%%i"
if not exist "%selected%\Backups" mkdir "%selected%\Backups"
if exist "%selected%\NR0000.%newExtension%.bk" copy "%selected%\NR0000.%newExtension%.bk" "%selected%\Backups\NR0000_%datetime%.%newExtension%.bk"
if exist "%selected%\NR0000.%newExtension%" copy "%selected%\NR0000.%newExtension%" "%selected%\NR0000.%newExtension%.bk"
copy "%selected%\NR0000.%targetExtension%" "%selected%\NR0000.%newExtension%"
if %ERRORLEVEL% neq 0 goto ProccessError
echo Success
pause
exit /b 0

@rem Error message
:ProccessError
echo Error, something went wrong.
pause
exit /b 1

:Select
set /p choice="Enter number: "
echo %choice%| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo Please enter a valid number.
    goto :Select
)
if %choice% gtr %count% (
    echo Number out of range.
    goto :Select
)
goto :eof
