Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# https://github.com/microsoft/vswhere/wiki/Start-Developer-Command-Prompt#using-powershell
& "${env:COMSPEC}" /s /c "`"$PSScriptRoot\pico-env.cmd`" && set" | ForEach-Object {
  $name, $value = $_ -split '=', 2
  
  # Check if the split produced a valid name and value, to ignore informative messages and empty lines
  if (-not [string]::IsNullOrEmpty($name) -and -not [string]::IsNullOrEmpty($value)) {
    Set-Content env:\"$name" $value
  }
}

Get-ChildItem env:PICO_*, env:OPENOCD_* | ForEach-Object { '{0}={1}' -f $_.Name, $_.Value }
