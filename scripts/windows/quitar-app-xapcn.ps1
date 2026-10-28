# Muestra y (si se confirma) elimina la app preinstalada "www.xapcn.com" de la Tienda.
# Guarda un informe en "xapcn-info.txt" junto a este script.
$ErrorActionPreference = 'SilentlyContinue'
$log = Join-Path $PSScriptRoot 'xapcn-info.txt'
$pk = @(Get-AppxPackage -AllUsers | Where-Object { $_.Name -like '*xapcn*' })
$prov = @(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*xapcn*' })
$txt = @()
foreach ($p in $pk) {
  $txt += "Paquete: $($p.PackageFullName)"
  $txt += "Carpeta: $($p.InstallLocation)"
  $m = Join-Path $p.InstallLocation 'AppxManifest.xml'
  if (Test-Path $m) {
    [xml]$x = Get-Content $m
    $txt += "Nombre visible: $($x.Package.Properties.DisplayName)"
    $txt += "Editor: $($x.Package.Properties.PublisherDisplayName)"
    $txt += "Descripcion: $($x.Package.Properties.Description)"
    $txt += "Aplicaciones: " + (($x.Package.Applications.Application | ForEach-Object { $_.Id + ' (' + $_.VisualElements.DisplayName + ')' }) -join ', ')
    $txt += "Permisos: " + (($x.Package.Capabilities.ChildNodes | ForEach-Object { $_.Name }) -join ', ')
  }
  $txt += ""
}
$txt += "Aprovisionado para usuarios nuevos: " + (($prov | ForEach-Object { $_.PackageName }) -join ', ')
$txt | Out-File $log -Encoding UTF8
$txt | ForEach-Object { Write-Host $_ }

if ($pk.Count -eq 0 -and $prov.Count -eq 0) { Write-Host "No se encontro la app." -ForegroundColor Yellow; Read-Host 'Intro para cerrar' | Out-Null; exit }
Write-Host ""
$r = Read-Host "Escribe S y pulsa Intro para DESINSTALARLA (cualquier otra cosa para no hacer nada)"
if ($r -match '^[sS]') {
  foreach ($p in $pk) { Remove-AppxPackage -Package $p.PackageFullName; Add-Content $log "Eliminado: $($p.PackageFullName)" }
  foreach ($p in $prov) { Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName | Out-Null; Add-Content $log "Desaprovisionado: $($p.PackageName)" }
  $left = @(Get-AppxPackage | Where-Object { $_.Name -like '*xapcn*' })
  if ($left.Count -eq 0) { Write-Host "App eliminada." -ForegroundColor Green; Add-Content $log 'RESULTADO: eliminada' }
  else { Write-Host "No se pudo eliminar del todo." -ForegroundColor Red; Add-Content $log 'RESULTADO: quedan restos' }
} else { Add-Content $log 'RESULTADO: no se elimino (usuario)' }
Read-Host 'Intro para cerrar' | Out-Null
