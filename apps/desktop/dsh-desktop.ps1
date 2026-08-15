$ErrorActionPreference = 'SilentlyContinue'

$InstallDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Port = if ($env:DSH_DESKTOP_PORT) { $env:DSH_DESKTOP_PORT } else { '3080' }
$Url = "http://127.0.0.1:$Port"
$ProfileDir = Join-Path $env:LOCALAPPDATA 'dsh-desktop\chromium-profile'
$LogFile = Join-Path $env:TEMP 'dsh-desktop.log'

if ($env:DSH_DESKTOP_URL) {
  $Url = $env:DSH_DESKTOP_URL
} else {
  $serving = $false
  try {
    $r = Invoke-WebRequest -Uri $Url -TimeoutSec 2 -UseBasicParsing
    if ($r.StatusCode -eq 200 -and $r.Content -match '__DSH_BOOT__') { $serving = $true }
  } catch { }

  if (-not $serving) {
    try {
      $r = Invoke-WebRequest -Uri $Url -TimeoutSec 2 -UseBasicParsing
      Write-Error "[dsh-desktop] Port $Port is used by another program. Stop it or set DSH_DESKTOP_URL to an existing DeepSeek Harness service."
      exit 1
    } catch { }

    $BinJs = Join-Path $InstallDir 'lib\bin.js'
    if (-not (Test-Path $BinJs)) {
      Write-Error "[dsh-desktop] Program not found: $BinJs"
      exit 1
    }

    $NodeExe = Join-Path $InstallDir 'node\node.exe'
    if (-not (Test-Path $NodeExe)) {
      $NodeCmd = Get-Command node -ErrorAction SilentlyContinue
      if (-not $NodeCmd) {
        Write-Error '[dsh-desktop] Node.js not found. Install Node.js 22+ or reinstall this program.'
        exit 1
      }
      $NodeExe = $NodeCmd.Source
    }
    $PsInfo = New-Object System.Diagnostics.ProcessStartInfo
    $PsInfo.FileName = $NodeExe
    $PsInfo.Arguments = "`"$BinJs`" web --port $Port"
    $PsInfo.WindowStyle = 'Hidden'
    $PsInfo.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($PsInfo) | Out-Null
    Start-Sleep -Seconds 1

    $ready = $false
    for ($i = 0; $i -lt 120; $i++) {
      try {
        $r = Invoke-WebRequest -Uri $Url -TimeoutSec 1 -UseBasicParsing
        if ($r.Content -match '__DSH_BOOT__') { $ready = $true; break }
      } catch { }
      Start-Sleep -Milliseconds 250
    }
    if (-not $ready) {
      Write-Error "[dsh-desktop] Service not ready, log: $LogFile"
      exit 1
    }
  }
}

$Browsers = @()
if ($env:DSH_DESKTOP_BROWSER) { $Browsers += $env:DSH_DESKTOP_BROWSER }
$Browsers += 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$Browsers += 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
$Browsers += "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
$Browsers += 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$Browsers += 'C:\Program Files\Microsoft\Edge\Application\msedge.exe'

$Browser = $null
foreach ($b in $Browsers) {
  if ($b -and (Test-Path $b)) { $Browser = $b; break }
}

if ($Browser) {
  Start-Process $Browser -ArgumentList "--app=$Url", "--user-data-dir=`"$ProfileDir`"", '--no-first-run', '--no-default-browser-check'
} else {
  Write-Error '[dsh-desktop] Chrome/Edge not found, opening in the default browser.'
  Start-Process $Url
}
