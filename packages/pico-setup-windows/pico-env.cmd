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

pushd "%~dp0"

for /f "skip=1 tokens=*" %%i in (version.ini) do (
  echo %%i
  set "%%i"
)

if not defined PICO_SDK_VERSION (
  echo ERROR: Unable to determine Pico SDK version.
  set /a errors += 1
)

for %%i in (sdk examples extras playground) do (
  rem Environment variables in Windows aren't case-sensitive, so we don't need
  rem to bother with uppercasing the env var name.
  if exist "%PICO_REPOS_PATH%\pico-%%i" (
    echo PICO_%%i_PATH=%PICO_REPOS_PATH%\pico-%%i
    set "PICO_%%i_PATH=%PICO_REPOS_PATH%\pico-%%i"
  )
)

popd

if exist "%PICO_INSTALL_PATH%\openocd" (
  echo OPENOCD_SCRIPTS=%PICO_INSTALL_PATH%\openocd\scripts
  set "OPENOCD_SCRIPTS=%PICO_INSTALL_PATH%\openocd\scripts"
  set "PATH=%PICO_INSTALL_PATH%\openocd;%PATH%"
)

rem GDB warns about being unable to determine a path for the index cache
rem directory if we do not set this.
set "HOME=%USERPROFILE%"

call :AddToPath "%PICO_INSTALL_PATH%\cmake\bin"
call :AddToPath "%PICO_INSTALL_PATH%\gcc-arm-none-eabi\bin"
call :AddToPath "%PICO_INSTALL_PATH%\ninja"
call :AddToPath "%PICO_INSTALL_PATH%\python"
call :AddToPath "%PICO_INSTALL_PATH%\git\cmd"
call :AddToPath "%PICO_INSTALL_PATH%\pico-sdk-tools"
call :AddToPath "%PICO_INSTALL_PATH%\picotool"

call :VerifyExe "GNU Arm Embedded Toolchain" "arm-none-eabi-gcc --version"
call :VerifyExe "CMake" "cmake --version"
call :VerifyExe "Ninja" "ninja --version"
call :VerifyExe "Python 3" "python --version"
call :VerifyExe "Git" "git --version"

rem We need Visual Studio Build Tools to compile pioasm and elf2uf2, but only
rem if we do not have pre-compiled versions available.
if not exist "%PICO_INSTALL_PATH%\pico-sdk-tools" (
  call :AddToPath "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
  call :AddToPath "%ProgramFiles%\Microsoft Visual Studio\Installer"

  rem https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt

  for /f "usebackq delims=" %%i in (`vswhere.exe -products * -requires "Microsoft.VisualStudio.Component.VC.Tools.x86.x64" -latest -property installationPath`) do (
    if exist "%%i\Common7\Tools\vsdevcmd.bat" (
      call "%%i\Common7\Tools\vsdevcmd.bat"
    )
  )

  call :VerifyExe "Visual Studio" "cl"
)

exit /b %errors%
