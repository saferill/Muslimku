param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('start', 'reload', 'restart', 'stop', 'status', 'tail')]
  [string]$Action,
  [string]$DeviceId = 'emulator-5554'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$sessionDir = Join-Path $root '.codex-hot-run'
$runnerScript = Join-Path $PSScriptRoot 'flutter_hot_runner.ps1'
$flutterExe = 'C:\Users\Hype AMD\flutter\bin\flutter.bat'
$runnerPidPath = Join-Path $sessionDir 'runner.pid'
$flutterPidPath = Join-Path $sessionDir 'flutter.pid'
$statePath = Join-Path $sessionDir 'state.txt'
$stdoutPath = Join-Path $sessionDir 'flutter.out.log'
$stderrPath = Join-Path $sessionDir 'flutter.err.log'

function Get-AliveProcess([string]$path) {
  if (-not (Test-Path $path)) { return $null }
  $storedPid = Get-Content $path | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($storedPid)) { return $null }
  try {
    return Get-Process -Id ([int]$storedPid) -ErrorAction Stop
  } catch {
    return $null
  }
}

switch ($Action) {
  'start' {
    New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null
    $runner = Get-AliveProcess $runnerPidPath
    if ($runner -ne $null) {
      Write-Output "Hot session already running (runner PID $($runner.Id))."
      break
    }
    $psExe = Join-Path $PSHOME 'powershell.exe'
    $process = Start-Process -FilePath $psExe `
      -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $runnerScript, '-FlutterExe', $flutterExe, '-WorkDir', $root, '-DeviceId', $DeviceId, '-SessionDir', $sessionDir `
      -WindowStyle Hidden `
      -PassThru
    Set-Content -Path $runnerPidPath -Value $process.Id
    Write-Output "Hot session started (runner PID $($process.Id))."
  }
  'reload' {
    New-Item -ItemType File -Force -Path (Join-Path $sessionDir 'reload.flag') | Out-Null
    Write-Output 'Hot reload requested.'
  }
  'restart' {
    New-Item -ItemType File -Force -Path (Join-Path $sessionDir 'restart.flag') | Out-Null
    Write-Output 'Hot restart requested.'
  }
  'stop' {
    New-Item -ItemType File -Force -Path (Join-Path $sessionDir 'stop.flag') | Out-Null
    Write-Output 'Hot session stop requested.'
  }
  'status' {
    $runner = Get-AliveProcess $runnerPidPath
    $flutter = Get-AliveProcess $flutterPidPath
    $state = if (Test-Path $statePath) { Get-Content $statePath | Select-Object -First 1 } else { 'missing' }
    [pscustomobject]@{
      RunnerPid = if ($runner) { $runner.Id } else { $null }
      FlutterPid = if ($flutter) { $flutter.Id } else { $null }
      State     = $state
      StdoutLog = $stdoutPath
      StderrLog = $stderrPath
    }
  }
  'tail' {
    if (Test-Path $stdoutPath) {
      Get-Content $stdoutPath -Tail 80
    }
    if (Test-Path $stderrPath) {
      "`n--- stderr ---"
      Get-Content $stderrPath -Tail 80
    }
  }
}
