$ErrorActionPreference = 'Stop'

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$entry = '127.0.0.1 sachithananthamp.com'

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Resolve-Path $PSCommandPath).Path
    exit 0
}

$lines = Get-Content $hostsPath -ErrorAction Stop
if ($lines -notcontains $entry) {
    Add-Content -Path $hostsPath -Value $entry
    Write-Host 'Added host entry: 127.0.0.1 sachithananthamp.com'
}
else {
    Write-Host 'Host entry already exists.'
}

$scriptPath = Join-Path (Split-Path -Parent $PSCommandPath) 'start_server.ps1'
Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath, '-Port', '80'
Write-Host 'Server launch requested on port 80.'
Write-Host 'Open http://sachithananthamp.com/ in your browser.'
