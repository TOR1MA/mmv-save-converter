@echo off

setlocal enabledelayedexpansion

set count=0
set newExtension="mmv"
set targetExtension="sl2"

for /d %%D in ("%APPDATA%\Nightreign\*") do (
    set /a count+=1
    set "folders[!count!]=%%D"
)

if %count% gtr 1 (
    echo Select Steam ID to convert save.
    for /l %%i in (1,1,%count%) do (
        echo %%i. !folders[%%i]!
    )
    set /p choice="Enter number: "
    call set "selected=%%folders[!choice!]%%"
) else (
    set "selected=!folders[1]!"
)

echo %selected%
for /f %%i in ('powershell -noprofile -command "Get-Date -Format \"yyyy-MM-dd_HH-mm-ss"\"') do set "datetime=%%i"
if not exist "%selected%\Backups" mkdir "%selected%\Backups"
if exist "%selected%\NR0000.%newExtension%.bak" copy "%selected%\NR0000.%newExtension%.bak" "%selected%\Backups\NR0000_%datetime%.%newExtension%.bak"
if exist "%selected%\NR0000.%newExtension%" copy "%selected%\NR0000.%newExtension%" "%selected%\NR0000.%newExtension%.bak"
copy "%selected%\NR0000.%targetExtension%" "%selected%\NR0000.%newExtension%"
if %ERRORLEVEL% neq 0 goto ProccessError
echo Success
pause

@Error message
:ProccessError
echo Error, something went wrong.
pause
