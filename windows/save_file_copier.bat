@echo off

setlocal enabledelayedexpansion

@rem Variables
set count=0
set newExtension=test
set targetExtensions="dbb=Daybreak Beta Save" "co2=Seamless co-op save (mmv 2.1.8 and older)" "sl2=Save file from Vanilla" "dev=Dev testing branch"

@rem Create a variable for each founded folder
for /d %%D in ("%APPDATA%\Nightreign\*") do (
    set /a count+=1
    set "folders[!count!]=%%D"
)

if %count% equ 0 (
    echo Can't find any Steam ID folders
    echo:
    pause
    exit /b 1
)

if %count% gtr 1 (
    echo Select Steam ID to convert save.
    echo:
    for /l %%i in (1,1,%count%) do (
        echo Enter %%i to select - !folders[%%i]!
    )
    call :Select
    call set "selected=%%folders[!choice!]%%"
) else (
    set "selected=!folders[1]!"
)

echo:
echo Selected SteamID folder - %selected%
echo:

@rem Get current date and time
for /f %%i in ('powershell -noprofile -command "Get-Date -Format \"yyyy-MM-dd_HH-mm-ss\""') do set "datetime=%%i"
if not exist "%selected%\Backups" mkdir "%selected%\Backups"

@rem List of saves
for %%i in (%targetExtensions%) do for /f "tokens=1,* delims==" %%a in (%%i) do (
    if exist "%selected%\NR0000.%%a" echo %%a - %%b
)
call :SaveSelect

@rem Create backup files and converts targetExtension save to newExtension
echo:
echo Selected SteamID folder - %selected%
echo NR0000.%targetExtension% will be copied as NR0000.%newExtension%.
if exist "%selected%\NR0000.%newExtension%" (
    if exist "%selected%\NR0000.%newExtension%" (
        echo:
        echo Save file with this extension "%newExtension%" already exists, if u want to replace it with new save confirm it.
        echo ^(previous save would be saved as NR0000.%newExtension%.bk file, in case u would want to revert it^)
        echo:
        call :Confirmation
    )
)
echo:
if exist "%selected%\NR0000.%newExtension%.bk" copy "%selected%\NR0000.%newExtension%.bk" "%selected%\Backups\NR0000_%datetime%.%newExtension%.bk"
if exist "%selected%\NR0000.%newExtension%" copy "%selected%\NR0000.%newExtension%" "%selected%\NR0000.%newExtension%.bk"
copy "%selected%\NR0000.%targetExtension%" "%selected%\NR0000.%newExtension%"

@rem Handle errors
if %ERRORLEVEL% neq 0 goto ProccessError
echo:
echo Success
echo:
pause
exit /b 0

@rem Error message
:ProccessError
echo:
echo Error, something went wrong.
echo:
pause
exit /b 1

@rem Steam ID selection menu
:Select
echo:
set /p choice="Enter a number: "
echo %choice%| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo:
    echo Please enter a valid number, use a single digit, e.g. 1 or 2.
    goto :Select
)
if %choice% gtr %count% (
    echo:
    echo Number out of range, use a single digit, e.g. 1 or 2.
    goto :Select
)
cls
goto :eof

@rem Save file selection menu
:SaveSelect
echo:
set /p "choice=Enter a save file extension: "
for %%i in (%targetExtensions%) do for /f "tokens=1,* delims==" %%a in (%%i) do (
    if /i "!choice!" == "%%a" (
        if not exist "%selected%\NR0000.%%a" (
            echo:
            echo Save file with .%%a extension doesn't exists, please select another one.
            goto :SaveSelect 
        )
        set "targetExtension=%%a"
        cls
        goto :eof
    )
)
echo:
echo Wrong save file extension ^(co2, sl2 and etc.^).
goto :SaveSelect

@rem Confirmation dialog
:Confirmation
echo Y - create a backup and convert the save file
echo N - cancel and exit
echo:
set /p "choice="

if /i "%choice%"=="Y" goto :eof
if /i "%choice%"=="YES" goto :eof
if /i "%choice%"=="N" call :Exit
if /i "%choice%"=="NO" call :Exit

echo:
echo Invalid choice
echo:
goto :Confirmation

@rem Script close msg
:Exit
echo:
echo The script was stopped, press any key to close the window
echo:
pause
exit 1
