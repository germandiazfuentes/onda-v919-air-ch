# Instala TODAS las actualizaciones pendientes de Windows Update y deja un registro.
# Uso (como administrador): powershell -ExecutionPolicy Bypass -File windows-update.ps1
# Se registra como tarea de SYSTEM porque la API de Windows Update no funciona en sesiones remotas (WinRM).
# Progreso: C:\ProgramData\soporte-dl\wu.log  (ResultCode 2 = correcto). Repetir hasta "Encontradas: 0".
param([switch]$Ejecutar)
$d = 'C:\ProgramData\soporte-dl'; New-Item -ItemType Directory -Force $d | Out-Null
if (-not $Ejecutar) {
  Copy-Item $PSCommandPath "$d\windows-update.ps1" -Force
  $a = New-ScheduledTaskAction -Execute powershell.exe -Argument "-NoProfile -ExecutionPolicy Bypass -File $d\windows-update.ps1 -Ejecutar"
  $p = New-ScheduledTaskPrincipal -UserId SYSTEM -RunLevel Highest
  $s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 6)
  Register-ScheduledTask -TaskName soporte-wu -Action $a -Principal $p -Settings $s -Force | Out-Null
  Start-ScheduledTask soporte-wu; "Lanzado. Sigue el registro: Get-Content $d\wu.log -Wait"; exit
}
$log = "$d\wu.log"
function L($m) { Add-Content $log "$(Get-Date -f 'dd/MM HH:mm:ss') $m" }
L '=== Inicio ==='
try {
  $ses = New-Object -ComObject Microsoft.Update.Session
  $sr = $ses.CreateUpdateSearcher()
  $res = $sr.Search("IsInstalled=0 and IsHidden=0 and Type='Software'")
  L "Encontradas: $($res.Updates.Count)"
  $col = New-Object -ComObject Microsoft.Update.UpdateColl
  foreach ($u in $res.Updates) {
    if ($u.InstallationBehavior.CanRequestUserInput) { L "OMITIDA (interactiva): $($u.Title)"; continue }
    if (-not $u.EulaAccepted) { $u.AcceptEula() }
    L "  + $($u.Title) [$([math]::Round($u.MaxDownloadSize/1MB))MB]"
    [void]$col.Add($u)
  }
  if ($col.Count -eq 0) { L 'Nada que instalar'; L '=== FIN ==='; exit }
  $dl = $ses.CreateUpdateDownloader(); $dl.Updates = $col
  L 'Descargando...'; $r = $dl.Download(); L "Descarga resultado: $($r.ResultCode)"
  $ins = $ses.CreateUpdateInstaller(); $ins.Updates = $col
  L 'Instalando...'; $r = $ins.Install()
  for ($i = 0; $i -lt $col.Count; $i++) { L "  $($r.GetUpdateResult($i).ResultCode) $($col.Item($i).Title)" }
  L "Instalacion resultado: $($r.ResultCode)  Reinicio necesario: $($r.RebootRequired)"
} catch { L "ERROR: $($_.Exception.Message)" }
L '=== FIN ==='
