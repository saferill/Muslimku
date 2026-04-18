param(
  [Parameter(Mandatory = $true)]
  [string]$FlutterExe,
  [Parameter(Mandatory = $true)]
  [string]$WorkDir,
  [Parameter(Mandatory = $true)]
  [string]$DeviceId,
  [Parameter(Mandatory = $true)]
  [string]$SessionDir
)

$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force -Path $SessionDir | Out-Null
$stdoutPath = Join-Path $SessionDir 'flutter.out.log'
$stderrPath = Join-Path $SessionDir 'flutter.err.log'
$statePath = Join-Path $SessionDir 'state.txt'
$reloadFlag = Join-Path $SessionDir 'reload.flag'
$restartFlag = Join-Path $SessionDir 'restart.flag'
$stopFlag = Join-Path $SessionDir 'stop.flag'
$flutterPidPath = Join-Path $SessionDir 'flutter.pid'
$runnerPidPath = Join-Path $SessionDir 'runner.pid'
$gradleHome = Join-Path $SessionDir 'gradle-home'
$tmpDir = Join-Path $SessionDir 'tmp'

New-Item -ItemType Directory -Force -Path $gradleHome, $tmpDir | Out-Null
Set-Content -Path $runnerPidPath -Value $PID
Set-Content -Path $statePath -Value 'starting'
if (Test-Path $stdoutPath) { Remove-Item -LiteralPath $stdoutPath -Force }
if (Test-Path $stderrPath) { Remove-Item -LiteralPath $stderrPath -Force }
New-Item -ItemType File -Path $stdoutPath | Out-Null
New-Item -ItemType File -Path $stderrPath | Out-Null

$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio1\jbr'
$env:ANDROID_HOME = 'C:\Users\Hype AMD\AppData\Local\Android\Sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:GRADLE_USER_HOME = $gradleHome
$env:TEMP = $tmpDir
$env:TMP = $tmpDir

$arguments = @(
  '/c',
  "`"$FlutterExe`" run -d $DeviceId --debug --hot --android-skip-build-dependency-validation --android-project-cache-dir .gradle-run-cache --no-pub --suppress-analytics"
)

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = 'cmd.exe'
$startInfo.WorkingDirectory = $WorkDir
$startInfo.Arguments = ($arguments -join ' ')
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardInput = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$process.EnableRaisingEvents = $true

$stdoutWriter = [System.IO.StreamWriter]::new($stdoutPath, $true)
$stderrWriter = [System.IO.StreamWriter]::new($stderrPath, $true)
$stdoutWriter.AutoFlush = $true
$stderrWriter.AutoFlush = $true

$null = Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action {
  if ($EventArgs.Data -ne $null) {
    Add-Content -Path $using:stdoutPath -Value $EventArgs.Data
  }
}
$null = Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action {
  if ($EventArgs.Data -ne $null) {
    Add-Content -Path $using:stderrPath -Value $EventArgs.Data
  }
}

$null = $process.Start()
Set-Content -Path $flutterPidPath -Value $process.Id
$process.BeginOutputReadLine()
$process.BeginErrorReadLine()
Set-Content -Path $statePath -Value 'running'

try {
  while (-not $process.HasExited) {
    if (Test-Path $reloadFlag) {
      Remove-Item -LiteralPath $reloadFlag -Force -ErrorAction SilentlyContinue
      $process.StandardInput.WriteLine('r')
      $process.StandardInput.Flush()
    }
    if (Test-Path $restartFlag) {
      Remove-Item -LiteralPath $restartFlag -Force -ErrorAction SilentlyContinue
      $process.StandardInput.WriteLine('R')
      $process.StandardInput.Flush()
    }
    if (Test-Path $stopFlag) {
      Remove-Item -LiteralPath $stopFlag -Force -ErrorAction SilentlyContinue
      $process.StandardInput.WriteLine('q')
      $process.StandardInput.Flush()
      break
    }
    Start-Sleep -Milliseconds 800
  }
  $process.WaitForExit()
  Set-Content -Path $statePath -Value "exited:$($process.ExitCode)"
} finally {
  $stdoutWriter.Dispose()
  $stderrWriter.Dispose()
  Get-EventSubscriber | Where-Object { $_.SourceObject -eq $process } | Unregister-Event
}
