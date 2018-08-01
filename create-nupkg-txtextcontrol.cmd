@echo off
setlocal enabledelayedexpansion

rem Determine script path
set mydir=%~dp0
set mydir=%mydir:~0,-1%

rem Defaults
set "defaultprogfiles=%ProgramW6432%\Text Control GmbH"
set defaultversioncontrol=25.0.1800.500
set defaultversionspell=7.0.600.500

set progfiles=
set versioncontrol=
set versionspell=

rem Verify command line, first parameter is to check non interactive execution
if /i "%1" == "-NonInteractive" goto silent
goto user

rem Non interactive execution
:silent
goto defaults

rem User input
:user
set /p progfiles=Installation directory for Text Control Suite, leave blank for default (%defaultprogfiles%): 
set /p versioncontrol=Package version TXTextControl, leave blank for default (%defaultversioncontrol%): 
set /p versionspell=Package version TXSpell, leave blank for default (%defaultversionspell%): 
goto defaults

rem Set default values when non are provided
:defaults
if "%progfiles%" == "" (
  set "progfiles=%defaultprogfiles%"
)

if "%versioncontrol%" == "" (
  set "versioncontrol=%defaultversioncontrol%"
)

if "%versionspell%" == "" (
  set "versionspell=%defaultversionspell%"
)

echo.
echo Using program files directory %progfiles%
echo Using version for TXTextControl %versioncontrol%
echo Using version for TXSpell %versionspell%
echo.

rem Execute nuget packaging
:pack

set progfilescontrol=
set progilesspell=

if "%versioncontrol:~1,1%" == "." (
  set "progfilescontrol=%progfiles%\TX Text Control %versioncontrol:~0,1%.0.NET for Windows Forms"
  goto verss
)
if "%versioncontrol:~2,1%" == "." (
  set "progfilescontrol=%progfiles%\TX Text Control %versioncontrol:~0,2%.0.NET for Windows Forms"
  goto verss
)
if "%versioncontrol:~3,1%" == "." (
  set "progfilescontrol=%progfiles%\TX Text Control %versioncontrol:~0,3%.0.NET for Windows Forms"
  goto verss
)

:verss
if "%versionspell:~1,1%" == "." (
  set "progfilesspell=%progfiles%\TX Spell %versionspell:~0,1%.0 .NET for Windows Forms"
  goto copybeforepack
)
if "%versionspell:~2,1%" == "." (
  set "progfilesspell=%progfiles%\TX Spell %versionspell:~0,2%.0 .NET for Windows Forms"
  goto copybeforepack
)
if "%versionspell:~3,1%" == "." (
  set "progfilesspell=%progfiles%\TX Spell %versionspell:~0,3%.0 .NET for Windows Forms"
  goto copybeforepack
)

:copybeforepack
echo %progfilescontrol%
echo %progfilesspell%

set "libpath=%mydir%\temp\tx"

if exist "%libpath%" rmdir /S /Q "%libpath%"
mkdir "%libpath%"
xcopy "%progfilescontrol%\Assembly" "%libpath%" /S /Y
xcopy "%progfilesspell%\Assembly" "%libpath%" /S /Y
xcopy "%mydir%\TXTextControl" "%libpath%" /S /Y

set "nuspecpath=%mydir%\.nuspec\TxTextControl"

for %%f in ("%nuspecpath%\*.nuspec") do (
  set "nuspec=%%f"
  nuget pack "!nuspec!" -Version "%version%" -OutputDirectory "%mydir%\bin" -BasePath "%libpath%"
)

rem End of file
:eof