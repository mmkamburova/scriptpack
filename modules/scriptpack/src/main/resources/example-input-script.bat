@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Initialization.
set WORKDIR=%~dp0
set WORKDIR=%WORKDIR:~0,-1%
set DEFAULT_APP_HOME=%WORKDIR%
set APP_HOME=%DEFAULT_APP_HOME%

REM Handling command line arguments.
REM IMPORTANT: You cannot use a goto-shift loop because it will not work.
if -%1-==-- set SHOW_HELP=1
for %%i in (%*) do (
  if defined INSTALL_DIR set APP_HOME=%%~i& set INSTALL_DIR=

  if -%%~i-==--d- set INSTALL_DIR=1
  if -%%~i-==--h- set SHOW_HELP=1
  if -%%~i-==---h- set SHOW_HELP=1
  if -%%~i-==---help- set SHOW_HELP=1
  if -%%~i-==---internal-skip-privilege-check- set SKIP_PRIV_CHECK=1
)

if defined SHOW_HELP (
    echo Usage: %~n0 [Options...]
    echo.
    echo Options:
    echo        -h, --h,--help            Help.
    echo        -d C:\myapp               Target installation directory.
REM echo        --internal-skip-privilege-check
REM echo                                  Skipping Administrator privileges check
REM echo                                  is internal and not documented.
    echo.
    exit /b 0
)

REM Optional. Remove the following lines if your application does not require Administrator privileges.
if not defined SKIP_PRIV_CHECK (
    REM An alternative is to use something like: whoami /priv | findstr SeCreateGlobalPrivilege | findstr Enabled
    net session > NUL 2>&1 || (
        echo Administrator privileges are required to execute this application. Run Command Prompt as Administrator and try again.
        exit /b 1
    )
)

REM Remove trailing slash
if %APP_HOME:~-1%==\ set APP_HOME=%APP_HOME:~0,-1%

md "%APP_HOME%" 2> NUL

REM at this point a variable with name APP_HOME must be defined with value pointing to the location where to extract the payload, for example C:\myapp
REM IMPORTANT: The following line is a placeholder and will be replaced with the actual code for extracting the payload.
REM PAYLOAD-EXTRACT-CODE


REM All code that runs the application goes here. The following code is an example for running a generic Java application.
:runApp
set JAVA="%APP_HOME%\jvm\bin\java"

set CLASSPATH=
for %%i in ("!APP_HOME!\libs\*.jar") do (
    if defined CLASSPATH (
        set CLASSPATH=!CLASSPATH!;"%%i"
    ) else (
        set CLASSPATH="%%i"
    )
)

%JAVA% -cp !CLASSPATH! fqn.of.main.Class %*

endlocal

exit /B %ERRORLEVEL%

REM The file must end with 3 "at" (@) characters and no new lines.
@@@