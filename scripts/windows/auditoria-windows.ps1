# Auditoria de telemetria - Onda V919 Air CH (Windows 10)
# Uso: clic derecho en el archivo -> "Ejecutar con PowerShell" (mejor como administrador)
# Genera la carpeta "informe-windows-<fecha>" junto a este script. Solo lee, no cambia nada.

$ErrorActionPreference = 'SilentlyContinue'
$out = Join-Path $PSScriptRoot ("informe-windows-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $out | Out-Null
function Save($name, $data) { $data | Out-File -FilePath (Join-Path $out $name) -Encoding UTF8 -Width 400 }

Write-Host "Recogiendo informacion del sistema..." -ForegroundColor Cyan
Save 'sistema.txt' (Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSLanguage, InstallDate, LastBootUpTime | Format-List | Out-String)
Save 'sistema.txt' ((Get-Content (Join-Path $out 'sistema.txt')) + (Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model | Format-List | Out-String))

Write-Host "Programas instalados..." -ForegroundColor Cyan
$keys = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
Save 'programas.csv' (Get-ItemProperty $keys | Where-Object DisplayName | Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, InstallDate | Sort-Object DisplayName | ConvertTo-Csv -NoTypeInformation)
Save 'apps-tienda.csv' (Get-AppxPackage -AllUsers | Select-Object Name, Publisher, Version | Sort-Object Name | ConvertTo-Csv -NoTypeInformation)

function SignerOf($path) {
  if (-not $path) { return '' }
  $p = $path.Trim('"') -replace '^"?([^"]+\.(exe|dll|sys))"?.*$','$1'
  if (-not (Test-Path $p)) { return "?($p)" }
  $s = Get-AuthenticodeSignature $p
  $v = (Get-Item $p).VersionInfo
  return ("{0} | {1} | {2}" -f $v.CompanyName, $s.Status, ($s.SignerCertificate.Subject -replace ',.*$',''))
}

Write-Host "Servicios..." -ForegroundColor Cyan
Save 'servicios.csv' (Get-CimInstance Win32_Service | ForEach-Object {
  [pscustomobject]@{ Name=$_.Name; DisplayName=$_.DisplayName; State=$_.State; StartMode=$_.StartMode; Path=$_.PathName; Firma=(SignerOf $_.PathName) } } | ConvertTo-Csv -NoTypeInformation)

Write-Host "Tareas programadas..." -ForegroundColor Cyan
Save 'tareas.csv' (Get-ScheduledTask | ForEach-Object {
  $a = $_.Actions | Select-Object -First 1
  [pscustomobject]@{ Path=$_.TaskPath; Name=$_.TaskName; State=$_.State; Author=$_.Author; Exec=$a.Execute; Args=$a.Arguments } } | ConvertTo-Csv -NoTypeInformation)

Write-Host "Programas de inicio..." -ForegroundColor Cyan
Save 'inicio.csv' (Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User | ConvertTo-Csv -NoTypeInformation)

Write-Host "Drivers..." -ForegroundColor Cyan
Save 'drivers.csv' (Get-CimInstance Win32_PnPSignedDriver | Where-Object DeviceName | Select-Object DeviceName, DriverProviderName, Manufacturer, DriverVersion, DriverDate, InfName | Sort-Object DriverProviderName | ConvertTo-Csv -NoTypeInformation)

Write-Host "Procesos..." -ForegroundColor Cyan
Save 'procesos.csv' (Get-Process | Select-Object Id, ProcessName, Path, Company, Description | ConvertTo-Csv -NoTypeInformation)

Save 'hosts.txt' (Get-Content "$env:windir\System32\drivers\etc\hosts")
Save 'proxy.txt' ((netsh winhttp show proxy | Out-String) + (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyEnable, ProxyServer, AutoConfigURL | Format-List | Out-String))

Write-Host "Cache DNS (dominios consultados desde el arranque)..." -ForegroundColor Cyan
Save 'dns-cache.csv' (Get-DnsClientCache | Select-Object Entry, Data, Type, TimeToLive | Sort-Object Entry | ConvertTo-Csv -NoTypeInformation)

Write-Host "Vigilando conexiones durante 3 minutos. Usa la tablet con normalidad (navegador, tienda...)." -ForegroundColor Yellow
$procs = @{}; Get-Process | ForEach-Object { $procs[$_.Id] = "$($_.ProcessName)|$($_.Path)" }
$seen = @{}
for ($i = 0; $i -lt 36; $i++) {
  Get-NetTCPConnection -State Established,SynSent | Where-Object { $_.RemoteAddress -notmatch '^(127\.|::1|0\.0\.0\.0|::$|fe80|192\.168\.|10\.|169\.254\.)' } | ForEach-Object {
    if (-not $procs.ContainsKey([int]$_.OwningProcess)) { $p = Get-Process -Id $_.OwningProcess; if ($p) { $procs[$p.Id] = "$($p.ProcessName)|$($p.Path)" } }
    $k = "$($_.RemoteAddress):$($_.RemotePort)|$($_.OwningProcess)"
    if (-not $seen.ContainsKey($k)) { $seen[$k] = [pscustomobject]@{ Hora=(Get-Date -Format 'HH:mm:ss'); Remoto=$_.RemoteAddress; Puerto=$_.RemotePort; PID=$_.OwningProcess; Proceso=$procs[[int]$_.OwningProcess] } }
  }
  Write-Progress -Activity "Vigilando conexiones" -PercentComplete ($i * 100 / 36)
  Start-Sleep -Seconds 5
}
Save 'conexiones.csv' ($seen.Values | Sort-Object Hora | ConvertTo-Csv -NoTypeInformation)
Save 'dns-cache-final.csv' (Get-DnsClientCache | Select-Object Entry, Data, Type | Sort-Object Entry | ConvertTo-Csv -NoTypeInformation)

Write-Host ""
Write-Host "Informe guardado en: $out" -ForegroundColor Green
Write-Host "Pulsa Intro para cerrar."
Read-Host | Out-Null
