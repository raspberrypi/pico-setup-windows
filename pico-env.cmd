@if not defined _echo echo off

set errors=0
goto main

:AddToPath

  if exist "%~1" (
    set "PATH=%~1;%PATH%"
  )

  goto :EOF

:VerifyExe

  echo Checking %1...
  cmd /c %2 >NUL 2>NUL
  if %ERRORLEVEL% neq 0 (
    echo ERROR: %1 is required but was not found.
    set /a errors += 1
  )

  goto :EOF

:main

for %%i in (sdk examples extras playground) do (
  rem Environment variables in Windows aren't case-sensitive, so we don't need
  rem to bother with uppercasing the env var name.
  if exist "%~dp0pico-%%i" (
    echo PICO_%%i_PATH=%~dp0pico-%%i
    set "PICO_%%i_PATH=%~dp0pico-%%i"
  )
)

call :AddToPath "%~dp0tools"

if exist "%~dp0openocd" (
  echo OPENOCD_SCRIPTS=%~dp0openocd\scripts
  set "OPENOCD_SCRIPTS=%~dp0openocd\scripts"
  set "PATH=%~dp0openocd;%PATH%"
)

call :AddToPath "%~dp0cmake\bin"
call :AddToPath "%~dp0gcc-arm\bin"
call :AddToPath "%~dp0ninja"
call :AddToPath "%~dp0python"
call :AddToPath "%~dp0git\cmd"

call :VerifyExe "GNU Arm Embedded Toolchain" "arm-none-eabi-gcc --version"
call :VerifyExe "CMake" "cmake --version"
call :VerifyExe "Ninja" "ninja --version"
call :VerifyExe "Python 3" "python --version"
call :VerifyExe "Git" "git --version"

exit /b %errors%
