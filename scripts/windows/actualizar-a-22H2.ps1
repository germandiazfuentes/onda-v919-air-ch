# Actualiza Windows 10 (p. ej. la 1511 de fábrica) a Windows 10 22H2 conservando datos y programas,
# usando el Asistente de actualización oficial de Microsoft, sin interfaz y como SYSTEM.
# Requisitos: cargador conectado (batería > 40 %), ~20 GB libres en C:, copia de drivers hecha.
# Tras terminar ejecuta restaurar-nvram-wifi.cmd si el WiFi no ve redes.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$d = 'C:\ProgramData\soporte-dl'; New-Item -ItemType Directory -Force $d | Out-Null

$libre = [math]::Round((Get-PSDrive C).Free/1GB,1)
"Libre en C: $libre GB"
if ($libre -lt 20) { powercfg /h off; "Hibernación desactivada para ganar espacio: $([math]::Round((Get-PSDrive C).Free/1GB,1)) GB" }

$ua = "$d\Windows10Upgrade.exe"
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkID=799445' -OutFile $ua -UseBasicParsing
$sig = Get-AuthenticodeSignature $ua
if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Microsoft Corporation') { throw "Firma no válida: $($sig.Status)" }

# Como tarea de SYSTEM: así funciona también lanzado desde una sesión remota (WinRM)
$a = New-ScheduledTaskAction -Execute $ua -Argument "/quietinstall /skipeula /auto upgrade /copylogs $d\ua-logs"
$p = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
$s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 8)
Register-ScheduledTask -TaskName 'soporte-upgrade-22H2' -Action $a -Principal $p -Settings $s -Force | Out-Null
Start-ScheduledTask -TaskName 'soporte-upgrade-22H2'
'Asistente lanzado. Fases: descarga (~4 GB, en C:\Windows\Temp) -> preparación (C:\$GetCurrent, C:\$Windows.~BT)'
'-> en C:\$Windows.~BT\Sources\Panther\setupact.log aparecerá "Rebooting system... prevented by command line override":'
'   entonces reinicia (Restart-Computer) y Windows instalará la 22H2 (45-90 min, varios reinicios).'
