# Reduce la telemetría y la publicidad de Windows 10 (válido para Home). Ejecutar como administrador.
# No rompe Windows Update, la Tienda ni Defender. Deshacer: reducir-telemetria-microsoft.ps1 -Deshacer
param([switch]$Deshacer)
$ErrorActionPreference = 'SilentlyContinue'

function Pol($ruta, $nombre, $valor) {
  if ($Deshacer) { Remove-ItemProperty $ruta -Name $nombre; return }
  # Ojo: New-Item -Force sobre una clave existente la vacía; crearla solo si falta
  if (-not (Test-Path $ruta)) { New-Item $ruta -Force | Out-Null }
  Set-ItemProperty $ruta -Name $nombre -Value $valor -Type DWord
}

$p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'
# Datos de diagnóstico al mínimo que admite Home (1 = "Obligatorios")
Pol "$p\DataCollection" AllowTelemetry 1
Pol "$p\DataCollection" AllowDeviceNameInTelemetry 0
Pol "$p\DataCollection" DoNotShowFeedbackNotifications 1
# Identificador de publicidad y experiencias personalizadas
Pol "$p\AdvertisingInfo" DisabledByGroupPolicy 1
Pol "$p\CloudContent" DisableWindowsConsumerFeatures 1
Pol "$p\CloudContent" DisableSoftLanding 1
# Historial de actividad (Timeline)
Pol "$p\System" EnableActivityFeed 0
Pol "$p\System" PublishUserActivities 0
Pol "$p\System" UploadUserActivities 0

# Ajustes por usuario: todos los perfiles cargados (usuarios con sesión iniciada)
Get-ChildItem Registry::HKEY_USERS | Where-Object { $_.PSChildName -match '^S-1-5-21-[\d-]+$' } | ForEach-Object {
  $u = "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion"
  Pol "$u\AdvertisingInfo" Enabled 0
  Pol "$u\Privacy" TailoredExperiencesWithDiagnosticDataEnabled 0
  Pol "$u\ContentDeliveryManager" SilentInstalledAppsEnabled 0
  Pol "$u\ContentDeliveryManager" SubscribedContent-338388Enabled 0
  Pol "$u\ContentDeliveryManager" SystemPaneSuggestionsEnabled 0
  Pol "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Siuf\Rules" NumberOfSIUFInPeriod 0
}

# Servicio de telemetría y tareas de recopilación
$modo = if ($Deshacer) { 'Automatic' } else { 'Disabled' }
foreach ($s in 'DiagTrack','dmwappushservice') {
  if (-not $Deshacer) { Stop-Service $s -Force }
  Set-Service $s -StartupType $modo
}
$tareas = '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
          '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
          '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
          '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
          '\Microsoft\Windows\Feedback\Siuf\DmClient',
          '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
foreach ($t in $tareas) {
  $n = Split-Path $t -Leaf; $r = (Split-Path $t -Parent) + '\'
  if ($Deshacer) { Enable-ScheduledTask -TaskPath $r -TaskName $n | Out-Null } else { Disable-ScheduledTask -TaskPath $r -TaskName $n | Out-Null }
}

# Resumen
"AllowTelemetry: $((Get-ItemProperty "$p\DataCollection").AllowTelemetry)"
Get-Service DiagTrack,dmwappushservice | ForEach-Object { "$($_.Name): $($_.Status) / $($_.StartType)" }
foreach ($t in $tareas) { $n = Split-Path $t -Leaf; $r = (Split-Path $t -Parent) + '\'; "$n : $((Get-ScheduledTask -TaskPath $r -TaskName $n).State)" }
